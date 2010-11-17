package "net-misc/openvpn"

directory "/etc/ssl/openvpn"

ssl_dh "/etc/ssl/openvpn/dh.pem"

ssl_ca "/etc/ssl/openvpn/ca"

ssl_certificate "/etc/ssl/openvpn/server" do
  cn node[:fqdn]
end

service "openvpn" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/openvpn/openvpn.conf" do
  source "openvpn.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "openvpn")
end

nagios_service "OPENVPN"
