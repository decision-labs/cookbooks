define :trac do
  include_recipe "trac"

  mysql_database "trac_#{params[:name]}" do
    owner "trac"
  end

  basedir = "/var/lib/trac"

  trac_name = params[:name]
  trac_dir = "#{basedir}/#{trac_name}"
  trac_pass = get_password("mysql/trac")
  trac_dsn = "mysql://trac:#{trac_pass}@localhost:3306/trac_#{params[:name]}"

  execute "tracinit-#{trac_name}" do
    command "trac-admin #{tracdir} initenv #{trac_name} #{trac_dsn} git file://#{trac_dir}"
    creates trac_dir
  end
end
