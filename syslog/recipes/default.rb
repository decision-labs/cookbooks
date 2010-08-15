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
  source "syslog-ng.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, resources(:service => "syslog-ng")
end

cookbook_file "/etc/logrotate.d/syslog-ng" do
  owner "root"
  group "root"
  mode "0644"
  source "syslog-ng.logrotate"
end
