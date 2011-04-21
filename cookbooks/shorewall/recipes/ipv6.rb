package "net-firewall/shorewall6"

execute "shorewall6-restart" do
  command "/sbin/shorewall6 restart"
  action :nothing
end

directory "/etc/shorewall6" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall6/shorewall6.conf" do
  source "ipv6/shorewall6.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, "execute[shorewall6-restart]"
end

if tagged?("ipsec")
  ipsec_nodes = search(:node, "tags:ipsec AND ipv6_enabled:true AND NOT fqdn:#{node[:fqdn]}")
else
  ipsec_nodes = []
end

%w(
  hosts
  interfaces
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall6/#{t}" do
    source "ipv6/#{t}"
    owner "root"
    group "root"
    mode "0600"
    variables :ipsec_nodes => ipsec_nodes
    notifies :run, "execute[shorewall6-restart]"
  end
end

service "shorewall6" do
  action [:enable, :start]
end
