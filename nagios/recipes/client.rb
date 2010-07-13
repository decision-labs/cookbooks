tag("nagios-client")

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

nagios_conf "nrpe" do
  subdir false
  variables :allowed => allowed
end
