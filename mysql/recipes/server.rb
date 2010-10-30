untag("nagios-MYSQL")
tag("mysql-server")

include_recipe "password"
include_recipe "mysql::default"

package "dev-db/maatkit"
package "dev-db/mysqltuner"
package "dev-ruby/mysql-ruby"

directory "/etc/mysql/conf.d" do
  owner "root"
  group "root"
  mode "0755"
end

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
  creates "/var/lib/mysql/mysql"
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

syslog_config "90-mysql" do
  template "syslog.conf"
end

cookbook_file "/etc/logrotate.d/mysql" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

%w(mysql.err mysql.log mysqld.err slow-queries.log).each do |l|
  file "/var/log/mysql/#{l}" do
    owner "mysql"
    group "wheel"
    mode "0640"
  end
end

service "mysql" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

mysql_nagios_password = get_password("mysql/nagios")

mysql_user "nagios" do
  force_password true
  password mysql_nagios_password
end

mysql_grant "nagios" do
  user "nagios"
  privileges ["PROCESS", "REPLICATION CLIENT"]
  database "*"
end

portage_package_keywords "=net-analyzer/nagios-check_mysql_health-2.1.1"

package "net-analyzer/nagios-check_mysql_health"

nagios_plugin "mysql_health_wrapper" do
  content "#!/bin/bash\nexec /usr/lib/nagios/plugins/check_mysql_health --hostname localhost --username nagios --password #{mysql_nagios_password} \"$@\""
end

%w(
  uptime
  ctime
  tchit
  qchit
  qclow
  slow
  long
  tabhit
  lock
  index
  tmptab
  kchit
  bphit
  bpwait
  logwait
).each do |name|
  node.default[:nagios][:services]["MYSQL-#{name.upcase}"][:enabled] = true
end
