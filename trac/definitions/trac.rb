define :trac, :action => :create do
  ## require recipe mysql
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
      variables({:git_path => '/usr/bin/git', :trac_env => trac_dir})
      backup 0
    end

    ## update the configuration to allow references to come in.
    execute "trac-ref-notifications-#{trac_name}" do
      [ 'tracopt.ticket.commit_updater.committicketupdater',
        'tracopt.ticket.commit_updater.committicketreferencemacro',
      ].each do |config_name|
        command "trac-admin #{trac_dir} config set components #{config_name} enabled"
      end
    end
  else
    directory trac_dir do
      action :delete
      recursive true
    end
  end
end
