include_recipe "portage"

service "syslog-ng" do
  action [ :disable, :stop ]
  only_if "test -e /etc/runlevels/default/syslog-ng"
end

package "app-admin/syslog-ng" do
  action :purge
end

package "app-admin/rsyslog"

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  mode "0640"
end

cookbook_file "/etc/logrotate.d/rsyslog" do
  source "rsyslog.logrotate"
end

service "rsyslog" do
  action [ :enable, :start ]
end
