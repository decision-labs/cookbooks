package "app-admin/logrotate"

directory "/etc/logrotate.d" do
  mode "0755"
end

cookbook_file "/etc/logrotate.conf" do
  source "logrotate.conf"
end

cron_daily "logrotate.cron" do
  command "/usr/sbin/logrotate /etc/logrotate.conf"
end
