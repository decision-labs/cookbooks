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

# third-party plugins
portage_package_keywords "=net-analyzer/nagios-check_pidfile-1"

# force eix-update, since it does not pick up initial overlays automatically
execute "eix-update" do
  not_if do File.exists?("/var/db/pkg/net-analyzer/nagios-check_pidfile-1") end
end

file "/usr/lib/nagios/plugins/check_pidfile" do
  action :delete
  not_if do File.exists?("/var/db/pkg/net-analyzer/nagios-check_pidfile-1") end
end

package "net-analyzer/nagios-check_pidfile"
