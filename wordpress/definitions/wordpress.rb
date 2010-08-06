require 'ostruct'
define :wordpress, :action => :create, :hostname => "localhost", :plugins => [] do
  
  wp_name       = params[:name].to_s.gsub(/[[:space:]]+/, "_")
  wp_toplevel   = "/var/lib/wordpress"
  destdir       = "#{wp_toplevel}/#{wp_name}"
  wp_mysql_user = OpenStruct.new(:name => "wp_#{wp_name}",
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
      backup 0
      action :create_if_missing
    end
    
    template "#{destdir}/wp-config.php" do
      owner "nginx"
      group "nginx"
      mode "644"
      cookbook "wordpress"
      source "wp-config.php.erb"
      variables({ :wp_mysql_user   => wp_mysql_user.name, 
                  :wp_mysql_pass   => wp_mysql_user.pass,
                  :wp_mysql_dbname => wp_mysql_user.name, 
                  :wp_salts_file   => "#{destdir}/.salts"})
      backup 0
    end

    template "/etc/nginx/servers/wp_#{wp_name}.conf" do
      source "wp.nginx.conf.erb"
      owner "root"
      group "root"
      mode "644"
      variables({:wp_server_name => params[:hostname], :wp_dirname => destdir })
      backup 0
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
    
    ## languages
    if params[:language]
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
        creates "#{destdir}/wp-content/languages/.#{params[:language]}"
        command(["unzip #{wp_toplevel}/#{filename}",
                 "touch .#{params[:language]}"].join(" && "))
      end
      
      execute "wp-language-install-#{wp_name}-#{params[:language]}-config" do
        user "nginx"
        group "nginx"
        cwd "#{destdir}"
        command "sed -i -e \"s/('WPLANG', '')/('WPLANG', '#{locale}')/\" #{destdir}/wp-config.php"
        not_if "grep WPLANG #{destdir}/wp-config.php | grep define | grep -q #{locale}"
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
    mysql_drop_user(wp_mysql_user) if mysql_user_exists?(wp_mysql_user)
    mysql_drop_database(wp_mysql_user.name) if mysql_database_exists?(wp_mysql_user.name)
  end
end
