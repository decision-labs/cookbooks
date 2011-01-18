include_recipe "portage"

package "app-portage/porticron"

template "/etc/porticron.conf" do
  source "porticron.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  backup 0
end

# we do this manually, since we cannot depend on the cron cookbook
%w(hourly weekly).each do |f|
  directory "/etc/cron.#{f}" do
    mode "0750"
  end
end

file "/etc/cron.daily/porticron" do
  action :delete
end

file "/etc/cron.weekly/porticron" do
  content "#!/bin/sh\n/usr/bin/lockrun --lockfile=/var/lock/porticron.cron -- /usr/sbin/porticron -n\n"
  mode "0755"
  backup 0
end

file "/etc/cron.weekly/distfiles" do
  content "#!/bin/sh\n/usr/bin/lockrun --lockfile=/var/lock/distfiles.cron -- /usr/bin/eclean --quiet distfiles\n"
  mode "0755"
  backup 0
end
