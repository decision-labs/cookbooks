tag("nagios-client")

include_recipe "password"

package "net-analyzer/nagios-nrpe"

directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

directory "/etc/nagios/nrpe.d" do
  owner "root"
  group "root"
  mode "0755"
end

service "nrpe" do
  supports :status => true
  action :enable
end

allowed = search(:node, "tags:nagios-master").map do |n| n['ipaddress'] end

mysql_nagios_password = get_password("mysql/nagios")

nagios_conf "nrpe" do
  subdir false
  mode "0640"
  variables :allowed => allowed, :mysql_nagios_password => mysql_nagios_password
end

nagios_plugin "pidfile" do
  source "check_pidfile"
end
