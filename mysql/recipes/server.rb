package "dev-db/mysql"
package "dev-db/maatkit"
package "dev-db/mysqltuner"

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
end

mysql_root_pass = get_password("mysql/root")

template "/usr/sbin/mysql_pkg_config" do
  source "mysql_pkg_config.erb"
  owner "root"
  group "root"
  mode "0755"
  not_if "test -d /var/lib/mysql/mysql"
  backup 0
  variables(:root_pass => mysql_root_pass)
end

execute "mysql_pkg_config" do
  not_if "test -d /var/lib/mysql/mysql"
end

file "/usr/sbin/mysql_pkg_config" do
  action :delete
  backup 0
end

file "/root/.my.cnf" do
  content "[client]\nuser = root\npass = #{mysql_root_pass}\n"
  owner "root"
  group "root"
  mode "0600"
  backup 0
end

cookbook_file "/etc/logrotate.d/mysql" do
  source "mysql.logrotate"
  owner "root"
  group "root"
  mode "0644"
end

service "mysql" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
