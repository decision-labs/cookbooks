untag("nagios-MYSQL")
tag("mysql-server")

include_recipe "password"
include_recipe "mysql::default"

portage_package_keywords "=dev-db/maatkit-7041"
portage_package_keywords "=dev-db/xtrabackup-bin-1.4"

package "dev-db/maatkit"
package "dev-db/mysqltuner"
package "dev-db/mytop"
package "dev-db/xtrabackup-bin"
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

template "/etc/logrotate.d/mysql" do
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
  params[:use_xtrabackup] ||= false
  params[:dbnames] ||= "all"
  params[:backupdir] ||= File.join(node[:mysql][:backupdir], name)
  params[:dbexclude] ||= ""
  params[:tabignore] ||= ""

  unless params[:use_xtrabackup]
    params[:opts] ||= "--single-transaction"
  end

  directory "#{params[:backupdir]}" do
    owner "root"
    group "root"
    mode "0700"
    recursive true
  end

  if params[:use_xtrabackup]
    file "#{node[:mysql][:backupdir]}/#{name}.sh" do
      content "#!/bin/bash\n/usr/bin/innobackupex #{params[:opts]} #{params[:backupdir]}\n"
      owner "root"
      group "root"
      mode "0700"
    end
  else
    template "#{node[:mysql][:backupdir]}/#{name}.sh" do
      source "mysqlbackup"
      owner "root"
      group "root"
      mode "0700"
      variables params
    end
  end

  cron_daily "00-mysqlbackup-#{name}" do
    command "/usr/bin/lockrun --lockfile=/var/lock/mysqlbackup-#{name}.cron -- #{node[:mysql][:backupdir]}/#{name}.sh"
  end

  cron_daily "mysqlbackup-#{name}" do
    action :delete
  end
end

# init script
service "mysql" do
  action [:enable, :start]
end

# nagios service checks
if tagged?("nagios-client")
  nrpe_command "check_mysql" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/mysqld/mysqld.pid /usr/sbin/mysqld"
  end

  nagios_service "MYSQL" do
    check_command "check_nrpe!check_mysql"
    notification_interval 15
    servicegroups "mysql"
  end

  nagios_service_escalation "MYSQL" do
    notification_interval 15
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

  { # name          command               warn crit check note enabled period
    :ctime    => %w(connection-time       1    5    1     15   1       24x7),
    :conns    => %w(threads-connected     75   100  1     15   1       24x7),
    :tchit    => %w(threadcache-hitrate   90:  80:  60    180  1       never),
    :qchit    => %w(qcache-hitrate        90:  80:  60    180  0       never),
    :qclow    => %w(qcache-lowmem-prunes  1    10   60    180  0       never),
    :slow     => %w(slow-queries          0.1  1    60    60   1       24x7),
    :long     => %w(long-running-procs    10   20   5     60   1       24x7),
    :tabhit   => %w(tablecache-hitrate    99:  95:  60    180  1       never),
    :lock     => %w(table-lock-contention 1    2    60    180  1       24x7),
    :index    => %w(index-usage           90:  80:  60    60   0       never),
    :tmptab   => %w(tmp-disk-tables       25   50   60    180  1       never),
    :kchit    => %w(keycache-hitrate      99:  95:  60    180  0       never),
    :bphit    => %w(bufferpool-hitrate    99:  95:  60    180  1       never),
    :bpwait   => %w(bufferpool-wait-free  1    10   60    180  1       never),
    :logwait  => %w(log-waits             1    10   60    180  1       never),
    :slaveio  => %w(slave-io-running      0    0    1     15   1       24x7),
    :slavesql => %w(slave-sql-running     0    0    1     15   1       24x7),
    :slavelag => %w(slave-lag             60   120  5     60   1       24x7),
  }.each do |name, p|
    name = name.to_s
    command_name = "check_mysql_#{name}"
    service_name = "MYSQL-#{name.upcase}"
    enabled = if p[5] == "1"
                true
              else
                false
              end

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mysql_health_wrapper --mode #{p[0]} --warning #{p[1]} --critical #{p[2]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!check_mysql_#{name}"
      check_interval p[3]
      notification_interval p[4]
      notification_period p[6]
      servicegroups "mysql"
      enabled enabled
    end

    nagios_service_dependency service_name do
      depends %w(MYSQL)
    end
  end

  if node[:mysql][:server][:skip_innodb]
    node.default[:nagios][:services]["MYSQL-BPHIT"][:enabled] = false
    node.default[:nagios][:services]["MYSQL-BPWAIT"][:enabled] = false
    node.default[:nagios][:services]["MYSQL-LOGWAIT"][:enabled] = false
  end

  unless node[:mysql][:server][:relay_log]
    node.default[:nagios][:services]["MYSQL-SLAVEIO"][:enabled] = false
    node.default[:nagios][:services]["MYSQL-SLAVESQL"][:enabled] = false
    node.default[:nagios][:services]["MYSQL-SLAVELAG"][:enabled] = false
  end

  nagios_service_dependency "MYSQL-SLAVELAG" do
    depends %w(MYSQL-SLAVEIO MYSQL-SLAVESQL)
  end

  nagios_service_escalation "MYSQL-SLAVEIO" do
    notification_interval 15
  end

  nagios_service_escalation "MYSQL-SLAVESQL" do
    notification_interval 15
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
