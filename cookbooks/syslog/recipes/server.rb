tag("syslog-server")

include_recipe "syslog"
include_recipe "syslog::tlsbase"

directory node[:syslog][:archivedir] do
  owner "root"
  group "root"
  mode 0755
end

syslog_config "00-server" do
  template "server.conf"
end

cron "rsyslog_gz" do
  action :delete
end

cron "syslog_gz" do
  minute "0"
  hour "4"
  command "find #{node[:syslog][:archivedir]}/$(date +\\%Y) -type f -mtime +1 -exec gzip -q {} \\;"
end
