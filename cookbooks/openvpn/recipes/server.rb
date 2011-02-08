package "net-misc/openvpn"

directory "/etc/ssl/openvpn"

ssl_dh "/etc/ssl/openvpn/dh.pem"

ssl_ca "/etc/ssl/openvpn/ca"

ssl_certificate "/etc/ssl/openvpn/server" do
  cn node[:fqdn]
end

template "/etc/openvpn/openvpn.conf" do
  source "openvpn.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvpn]"
end

service "openvpn" do
  action [:enable, :start]
end

nrpe_command "check_openvpn" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/openvpn.pid /usr/sbin/openvpn"
end

nagios_service "OPENVPN" do
  check_command "check_nrpe!check_openvpn"
end
