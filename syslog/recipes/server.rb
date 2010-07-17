tag("syslog-server")

include_recipe "syslog"

directory node[:rsyslog][:logdir] do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/rsyslog.d/server.conf" do
  source "server.conf.erb"
  backup false
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "rsyslog"), :delayed
end

file "/etc/rsyslog.d/remote.conf" do
  action :delete
  notifies :reload, resources(:service => "rsyslog"), :delayed
end

cron "rsyslog_gz" do
  minute "0"
  hour "4"
  command "find #{node[:rsyslog][:logdir]}/$(date +\\%Y) -type f -mtime +1 -exec gzip -q {} \\;"
end
