untag("nagios-CRON")

include_recipe "portage"

portage_package_keywords "=sys-process/dcron-4.5_pre20100203" do
end

# force eix-update, since it does not pick up initial overlays automatically
execute "eix-update" do
  not_if do File.exists?("/var/db/pkg/sys-process/dcron-4.5_pre20100203") end
end

%w(sys-process/dcron dev-util/lockrun).each do |p|
  package p do
    action :upgrade
  end
end

service "dcron" do
  action :enable
end

%w(d hourly daily weekly monthly).each do |dir|
  directory "/etc/cron.#{dir}" do
    mode "0750"
  end
end

template "/etc/conf.d/dcron" do
  source "dcron.confd.erb"
  mode "0644"
  notifies :restart, resources(:service => "dcron")
end

file "/etc/crontab" do
  action :delete
  backup 0
end

cron "lastrun-hourly" do
  minute node[:cron][:hourly][:minute]
  command "rm -f /var/spool/cron/lastrun/cron.hourly"
end

cron "lastrun-daily" do
  minute node[:cron][:daily][:minute]
  hour node[:cron][:daily][:hour]
  command "rm -f /var/spool/cron/lastrun/cron.daily"
end

cron "lastrun-weekly" do
  minute node[:cron][:weekly][:minute]
  hour node[:cron][:weekly][:hour]
  weekday node[:cron][:weekly][:wday]
  command "rm -f /var/spool/cron/lastrun/cron.weekly"
end

cron "lastrun-monthly" do
  minute node[:cron][:monthly][:minute]
  hour node[:cron][:monthly][:hour]
  day node[:cron][:monthly][:wday]
  command "rm -f /var/spool/cron/lastrun/cron.monthly"
end

cron "run-crons" do
  minute "*/10"
  command "/usr/bin/test -x /usr/sbin/run-crons && /usr/sbin/run-crons"
end

cron "heartbeat" do
  command "/usr/bin/touch /tmp/.check_cron"
end

nagios_plugin "cron" do
  source "check_cron"
end
