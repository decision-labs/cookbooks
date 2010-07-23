include_recipe "portage"

service "syslog-ng" do
  action [ :disable, :stop ]
  only_if "test -e /etc/runlevels/default/syslog-ng"
end

package "app-admin/syslog-ng" do
  action :purge
end

package "app-admin/rsyslog"

service "rsyslog" do
  supports :reload => true, :status => true
  action :enable
end

directory "/etc/rsyslog.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  notifies :reload, resources(:service => "rsyslog")
end

cookbook_file "/etc/logrotate.d/rsyslog" do
  owner "root"
  group "root"
  mode "0644"
  source "rsyslog.logrotate"
end
