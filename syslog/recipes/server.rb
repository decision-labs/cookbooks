tag("syslog-server")

include_recipe "syslog"
include_recipe "syslog::tlsbase"

directory node[:syslog][:archivedir] do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/syslog-ng/conf.d/00-server.conf" do
  source "server.conf.erb"
  backup false
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "syslog-ng")
end

cron "rsyslog_gz" do
  action :delete
end

cron "syslog_gz" do
  minute "0"
  hour "4"
  command "find #{node[:syslog][:archivedir]}/$(date +\\%Y) -type f -mtime +1 -exec gzip -q {} \\;"
end
