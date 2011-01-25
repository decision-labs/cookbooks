package "mail-filter/postgrey"

service "postgrey" do
  action :enable
end

template "/etc/conf.d/postgrey" do
  source "postgrey.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "postgrey")
end

nrpe_command "check_postgrey" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/postgrey.pid /usr/sbin/postgrey"
end

nagios_service "POSTGREY" do
  check_command "check_nrpe!check_postgrey"
  servicegroups "postfix"
end
