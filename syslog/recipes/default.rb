service "rsyslog" do
  action [ :disable, :stop ]
  only_if "test -e /etc/runlevels/default/rsyslog"
end

package "app-admin/rsyslog" do
  action :purge
end

%w(
  /etc/rsyslog.conf
  /etc/logrotate.d/rsyslog
).each do |f|
  file f do
    action :delete
  end
end

directory "/etc/rsyslog.d" do
  action :delete
  recursive true
end

package "app-admin/syslog-ng"

service "syslog-ng" do
  supports :status => true
  action :enable
end

directory "/etc/syslog-ng/conf.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, resources(:service => "syslog-ng")
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

# nagios service checks
if tagged?("nagios-client")
  node.default[:nagios][:services]["SYSLOG"][:enabled] = true
end
