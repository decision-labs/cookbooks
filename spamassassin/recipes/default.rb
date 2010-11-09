include_recipe "portage"

group "spamd" do
  gid 638
end

user "spamd" do
  uid 638
  gid 638
  home "/var/lib/spamassassin"
end

portage_package_keywords "=mail-filter/spamassassin-3.3.1-r3"

%w(
  dev-python/pyzor
  mail-filter/dcc
  mail-filter/razor
  mail-filter/spamassassin
).each do |p|
  package p
end

directory "/var/lib/spamassassin" do
  owner "spamd"
  group "spamd"
end

execute "/usr/bin/sa-update" do
  creates "/etc/spamassassin/sa-update-keys"
end

service "spamd" do
  action :enable
end

template "/etc/conf.d/spamd" do
  source "spamd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "spamd")
end

nagios_service "SPAMD"
