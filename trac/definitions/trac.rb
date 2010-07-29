define :trac, :action => :create do
  include_recipe "trac"

  mysql_database "trac_#{params[:name]}" do
    owner "trac"
    action params[:action]
  end

  basedir = "/var/lib/trac"

  trac_name = params[:name]
  trac_dir  = "#{basedir}/#{trac_name}"
  trac_pass = get_password("mysql/trac")
  trac_dsn  = "mysql://trac:#{trac_pass}@localhost:3306/trac_#{trac_name}"
  git_dir   = "/var/spool/gitosis/repositories/#{trac_name}.git"

  if params[:action] == :create
    gitosis_repo trac_name

    execute "tracinit-#{trac_name}" do
      command [("trac-admin #{trac_dir} initenv --inherit=/etc/trac/trac.ini "+
                "#{trac_name} #{trac_dsn} git #{git_dir}"),
               "trac-admin #{trac_dir} permission add admin TRAC_ADMIN",
               "chown tracd:tracd -R #{trac_dir}",
               "mysql trac_#{trac_name} < /etc/trac/initial.sql"
              ].join(" && ")
      creates trac_dir
    end

    # create the post-receive hook to update trac which ticket refs
    template "#{git_dir}/hooks/post-receive" do
      owner "git"
      group "git"
      mode "750"
      cookbook "trac"
      source "post-receive.erb"
      variables({:project_name => trac_name})
      backup 0
    end

    # obtain the send email post-receive script from kernel.org
    remote_file "#{git_dir}/hooks/post-receive-email" do
      owner "git"
      group "git"
      mode "750"
      source "http://git.kernel.org/?p=git/git.git;a=blob_plain;f=contrib/hooks/post-receive-email;h=60cbab65d3f8230be3041a13fac2fd9f9b3018d5;hb=HEAD"
      checksum "ea349399d4ef3889af501579e3bdd1567245194cb0b709086aa8a821e0fb7384"
      action :create_if_missing
      backup 0
    end

    # this is to update the trac with references
    template "#{git_dir}/hooks/post-receive-trac-update" do
      owner "git"
      group "git"
      mode "750"
      cookbook "trac"
      source "post-receive-trac-update.erb"
      variables({:git_path => '/usr/bin/git', :trac_env => trac_dir})
      backup 0
    end

    ## update the description
    file "#{git_dir}/description" do
      owner "git"
      group "git"
      mode "640"
      content "#{trac_name.gsub(/^./) {|firstletter| firstletter.upcase }}"
    end
    
    ## update the configuration to allow references to come in.
    ['tracopt.ticket.commit_updater.committicketreferencemacro',
     'tracopt.ticket.commit_updater.committicketupdater',
    ].each do |config_name|
      execute "trac-ref-notifications-#{trac_name}-#{config_name}" do
        command "trac-admin #{trac_dir} config set components #{config_name} enabled"
        not_if "grep #{config_name} #{trac_dir}/conf/trac.ini | grep enabled"
      end
    end
    
    ## set some configuration required for sending email 
    { "mailinglist"  => "gerrit@teameurope.net,mathias@teameurope.net",
      "announcelist" => "",
      "emailprefix"  => "[GIT] "
    }.each do |key,value|
      execute "git-config-hooks-#{trac_name}-#{key}" do
        command "git config --add hooks.#{key} \"#{value}\""
        not_if "grep -q #{key} #{git_dir}/config"
        cwd git_dir
        user "git"
        group "git"
      end
    end

    ## ensure that the file has the correct ownership
    file "#{trac_dir}/conf/trac.ini" do
      owner "tracd"
      group "tracd"
      mode "644"
    end
  else
    directory trac_dir do
      action :delete
      recursive true
    end
  end
end
