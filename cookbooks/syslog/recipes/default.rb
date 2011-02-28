package "app-admin/syslog-ng"

directory "/etc/syslog-ng/conf.d" do
  owner "root"
  group "root"
  mode "0755"
end

service "syslog-ng" do
  action [:enable, :start]
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[syslog-ng]"
end

syslog_config "00-local" do
  template "local.conf"
end

include_recipe "syslog::logrotate"

cookbook_file "/etc/logrotate.d/syslog-ng" do
  owner "root"
  group "root"
  mode "0644"
  source "syslog-ng.logrotate"
end

nrpe_command "check_syslog" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/syslog-ng.pid /usr/sbin/syslog-ng"
end

nagios_service "SYSLOG" do
  check_command "check_nrpe!check_syslog"
  servicegroups "system"
end
