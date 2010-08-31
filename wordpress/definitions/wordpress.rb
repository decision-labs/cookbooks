require 'ostruct'

define :wordpress, :action => :create, :hostname => "localhost", :plugins => [] do
  
  wp_name         = params[:name].to_s.gsub(/[[:space:]]+/, "_")
  wp_toplevel     = "/var/lib/wordpress"
  destdir         = "#{wp_toplevel}/#{wp_name}"
  mysql_cnf_patch = "/etc/mysql/my.cnf.wordpress.patch.1"
  wp_mysql_user   = OpenStruct.new(:name => "wp_#{wp_name}",
                                   :pass => get_password("mysql/wp_#{wp_name}"),
                                   :host => 'localhost')

  if params[:action] == :create

    unless mysql_user_exists?(wp_mysql_user)
      mysql_create_user(wp_mysql_user, wp_mysql_user.pass) 
    end

    mysql_database wp_mysql_user.name do
      owner wp_mysql_user.name
      action :create
    end
    
    execute "wp-create-#{wp_name}" do
      user "nginx"
      group "nginx"
      cwd wp_toplevel
      creates destdir
      command "cp -a #{wp_toplevel}/_src_ #{destdir} && rm -f #{destdir}/wp-config.php"
    end
    
    remote_file "#{destdir}/.salts" do
      source "https://api.wordpress.org/secret-key/1.1/salt/"
      action :create_if_missing
    end
    
    ## language
    wp_locale = (if params[:language]
                   lang,form = params[:language].split(/[.]/)
                   locale = (case lang.downcase
                             when "de" then "de_DE"
                             else "NL:[#{lang}]"
                             end)
                   filename = locale + ".mo_" + (case form.downcase
                                                 when "sie" then "SIE"
                                                 when "du" then "DU"
                                                 else "NF:[#{form}]"
                                                 end) + ".zip"

                   directory "#{destdir}/wp-content/languages" do
                     owner "nginx"
                     group "nginx"
                     mode "750"
                   end

                   execute "wp-language-install-#{wp_name}-#{params[:language]}" do
                     user "nginx"
                     group "nginx"
                     cwd "#{destdir}/wp-content/languages"
                     creates "#{destdir}/wp-content/languages/#{locale}.mo"
                     command(["unzip #{wp_toplevel}/#{filename}",
                              "touch .#{params[:language]}"].join(" && "))
                   end
                   locale
                 else 
                   nil
                 end)

    template "#{destdir}/wp-config.php" do
      owner "nginx"
      group "nginx"
      mode "644"
      cookbook "wordpress"
      source "wp-config.php.erb"
      variables({ :wp_mysql_user   => wp_mysql_user.name, 
                  :wp_mysql_pass   => wp_mysql_user.pass,
                  :wp_mysql_dbname => wp_mysql_user.name, 
                  :wp_salts_file   => "#{destdir}/.salts",
                  :wp_locale       => wp_locale})
    end

    file "/etc/nginx/servers/wp_#{wp_name}.conf" do
      action :delete
    end
    [params[:hostname]].flatten.each do |hostname|
      template "/etc/nginx/servers/wp_#{wp_name}.#{hostname}.conf" do
        source "wp.nginx.conf.erb"
        owner "root"
        group "root"
        mode "644"
        variables({:wp_server_name => hostname, :wp_dirname => destdir })
      end
    end

    ## install plugins as required.
    params[:plugins].each do |plugin_name|
      pdirname, pversion, parchive = plugin_name.
        match(/(^[^.]+)[.](.+)[.](zip|tar.gz|tar.bz2|tgz|tar)/).to_a[1..3]

      execute "wp-plugin-install-#{wp_name}-#{plugin_name}" do
        user "nginx"
        group "nginx"
        cwd "#{destdir}/wp-content/plugins"
        creates "#{destdir}/wp-content/plugins/#{pdirname}"
        command((case parchive.downcase
                 when "zip"     then "unzip"
                 when "tgz"     then "tar xfz"
                 when "tar.gz"  then "tar xfz"
                 when "tar.bz2" then "tar xfj"
                 when "tar"     then "tar xf"
                 else "echo 'unknown file format'"
                 end) + " #{wp_toplevel}/#{plugin_name}")
      end
    end

    ## copy the memcache object cache file to the installation
    execute "use memcache as object cache" do
      user "nginx"
      group "nginx"
      cwd "#{destdir}/wp-content"
      creates "#{destdir}/wp-content/object-cache.php"
      command("cp #{wp_toplevel}/object-cache.php #{destdir}/wp-content/")
    end

    # create a file with the missing indexes and apply if necessary
    mysql_missing_indexes = "#{destdir}/.mysql.missing.indexes"
    cookbook_file mysql_missing_indexes do
      owner "nginx"
      group "nginx"
      source "mysql.add.indicies"
      cookbook "wordpress"
    end
    execute "create missing mysql indexes" do
      user 'root'
      group 'root'
      command "cat #{mysql_missing_indexes} | mysql --database=#{wp_mysql_user.name}"
      not_if "mysql --database=#{wp_mysql_user.name} -e 'show indexes in wp_term_taxonomy;' | grep wp_term_taxonomy_term_id"
    end

    # patch the my.cnf with wordpress improvements
    cookbook_file mysql_cnf_patch do
      owner "root"
      group "root"
      source "my.cnf.patch"
      cookbook "wordpress"
    end
    execute "apply mysql cnf patch" do
      user 'root'
      group 'root'
      command "patch /etc/mysql/my.cnf < #{mysql_cnf_patch}"
      not_if "grep '# Patch: Wordpress-1' /etc/mysql/my.cnf"
    end

    # make MyISAM tables become InnoDB
    convert_myisam_to_innodb = "#{destdir}/.myisam_to_innodb"
    template convert_myisam_to_innodb do
      owner "nginx"
      group "nginx"
      source "myisam_to_innodb.erb"
      cookbook "wordpress"
      variables({:mysql_database => wp_mysql_user.name})
    end
    execute "convert MyISAM to InnoDB" do
      user 'root'
      group 'root'
      command "/bin/bash #{convert_myisam_to_innodb}"
      not_if "mysql --database=#{wp_mysql_user.name} -e 'show create table wp_posts;' | grep -i engine=innodb"
    end

    tracking_snippet_file = "#{destdir}/.tracking_snippet"
    template tracking_snippet_file do
      owner "nginx"
      group "nginx"
      source "tracking.html.erb"
      cookbook "wordpress"
      variables(params[:tracking_opts].
                merge({ :wp_hostnames => [params[:hostname]].flatten,
                        :wp_name      => wp_name,
                        :wp_locale    => wp_locale,
                        :wp_destdir   => destdir }))
    end
      
    `find #{destdir} -name footer.php -print`.split("\n").each do |file_name|
      ## check for tracking in each footer.php file.
      script "include tracking into #{file_name}" do
        interpreter "ruby"
        user "nginx"
        group "nginx"
        not_if "grep -q START_TRACKING_TAG #{file_name}"
        code(<<-EOF)
         def gsub_file(path, regexp, *args, &block)
           unless File.exists?(path)
             raise "ERROR: FILE DOES NOT EXIST: [%s] - Exiting" % path
           end
           content = File.read(path).gsub(regexp, *args, &block)
           File.open(path, 'wb') { |file| file.write(content) }
         end

         def insert_tracking(tracking_file, target_file)
           unless File.exists?(tracking_file)
             raise "ERROR: TRACKING DOES NOT EXIST: [%s] - Exiting" % tracking_file
           end
           gsub_file(target_file, /^[<]\\/body[>]/) do |match|
             [File.open(tracking_file).read,"</body>"].join("\n")
           end
         end

         begin
           insert_tracking('#{tracking_snippet_file}', '#{file_name}')
         rescue Exception => e 
           puts e
           File.open("/tmp/fubar.errors", "wb"){|file| file.write(e.to_s) }
           exit 1
         end
         exit 0
        EOF
      end
    end

  else
    ##
    ## Assume delete action.
    ##
    directory destdir do
      action params[:action]
      recursive true
    end
    file "/etc/nginx/servers/wp_#{wp_name}.conf" do
      action :delete
    end
    file mysql_cnf_patch do
      action :delete
    end
    [params[:hostname]].flatten.each do |hostname|
      file "/etc/nginx/servers/wp_#{wp_name}.#{hostname}.conf" do
        action :delete
      end
    end
    mysql_drop_user(wp_mysql_user) if mysql_user_exists?(wp_mysql_user)
    mysql_drop_database(wp_mysql_user.name) if mysql_database_exists?(wp_mysql_user.name)
  end
end
