include_recipe "portage"

portage_pkg "app-admin/rsyslog"

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
