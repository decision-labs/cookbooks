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

nrpe_command "check_time" do
  command "/usr/lib/nagios/plugins/check_ntp_time -H ptbtime1.ptb.de"
end

nagios_service "TIME" do
  check_command "check_nrpe!check_time"
  servicegroups "system"
end
