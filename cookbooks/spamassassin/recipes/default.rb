include_recipe "portage"

group "spamd" do
  gid 638
end

user "spamd" do
  uid 638
  gid 638
  home "/var/lib/spamassassin"
end

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

template "/etc/conf.d/spamd" do
  source "spamd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[spamd]"
end

service "spamd" do
  action [:enable, :start]
end

nrpe_command "check_spamd" do
  command "/usr/bin/sa-check_spamd -H localhost -t 10 -w 5 -c 10"
end

nagios_service "SPAMD" do
  check_command "check_nrpe!check_spamd"
end
