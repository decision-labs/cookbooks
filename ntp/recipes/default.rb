untag("nagios-TIME")

package "net-misc/openntpd"

service "ntpd" do
  supports :status => true
  action :enable
end

cookbook_file "/etc/conf.d/ntpd" do
  source "ntpd.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "ntpd"), :delayed
end

file "/etc/ntpd.conf" do
  content "server #{node[:ntp][:server]}\n"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "ntpd"), :delayed
end

node.default[:nagios][:services]["TIME"][:enabled] = true
