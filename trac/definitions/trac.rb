define :trac, :action => :create do
  include_recipe "trac"

  mysql_database "trac_#{params[:name]}" do
    owner "trac"
    action params[:action]
  end

  basedir = "/var/lib/trac"

  trac_name = params[:name]
  trac_dir = "#{basedir}/#{trac_name}"
  trac_pass = get_password("mysql/trac")
  trac_dsn = "mysql://trac:#{trac_pass}@localhost:3306/trac_#{trac_name}"
  git_dir = "/var/spool/gitosis/repositories/#{trac_name}.git"

  if params[:action] == :create
    gitosis_repo trac_name

    execute "tracinit-#{trac_name}" do
      command "trac-admin #{trac_dir} initenv --inherit=/etc/trac/trac.ini #{trac_name} #{trac_dsn} git #{git_dir} && trac-admin #{trac_dir} permission add admin TRAC_ADMIN && chown tracd:tracd -R #{trac_dir} && mysql trac_#{trac_name} < /etc/trac/initial.sql"
      creates trac_dir
    end
  else
    directory trac_dir do
      action :delete
      recursive true
    end
  end
end
