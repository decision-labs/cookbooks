untag("nagios-MYSQL")
tag("mysql-server")

include_recipe "password"
include_recipe "mysql::default"

package "dev-db/maatkit"
package "dev-db/mysqltuner"
package "dev-ruby/mysql-ruby"

# configuration files
directory "/etc/mysql/conf.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/mysql/my.cnf" do
  source "my.cnf"
  owner "root"
  group "root"
  mode "0644"
end

# create initial database and users
mysql_root_pass = get_password("mysql/root")

template "/usr/sbin/mysql_pkg_config" do
  source "mysql_pkg_config"
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

# syslog and logrotate configuration
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

# backup
node[:mysql][:backups].each do |name, params|
  params = {
    :dbnames => "all",
    :backupdir => File.join(node[:mysql][:backupdir], name),
    :dbexclude => "",
    :tabignore => "",
    :opts => "--single-transaction"
  }.merge(params)

  directory "#{node[:mysql][:backupdir]}/#{name}" do
    owner "root"
    group "root"
    mode "0700"
    recursive true
  end

  template "#{node[:mysql][:backupdir]}/#{name}.sh" do
    source "mysqlbackup"
    owner "root"
    group "root"
    mode "0700"
    variables params
  end

  cron_daily "mysqlbackup-#{name}" do
    command "/usr/bin/lockrun --lockfile=/var/lock/mysqlbackup-#{name}.cron -- #{node[:mysql][:backupdir]}/#{name}.sh"
  end
end

# init script
service "mysql" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

# nagios service checks
if tagged?("nagios-client")
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

  nagios_service "MYSQL"

  %w(
    ctime
    conns
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
    nagios_service "MYSQL-#{name.upcase}"
  end
end

# munin plugins
if tagged?("munin-node")
  mysql_munin_password = get_password("mysql/munin")

  mysql_user "munin" do
    force_password true
    password mysql_munin_password
  end

  mysql_grant "munin" do
    user "munin"
    privileges ["PROCESS", "REPLICATION CLIENT"]
    database "*"
  end

  munin_plugin "mysql_slave_status" do
    source "mysql_slave_status"
    config ["env.mysqlopts --user=munin --password=#{mysql_munin_password}"]
  end

  %w(bytes queries slowqueries threads).each do |p|
    munin_plugin "mysql_#{p}" do
      config ["env.mysqlopts --user=munin --password=#{mysql_munin_password}"]
    end
  end
end
