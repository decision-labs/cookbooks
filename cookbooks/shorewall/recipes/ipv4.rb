# remove old cruft
%w(common perl shell).each do |p|
  package "net-firewall/shorewall-#{p}" do
    action :remove
  end
end

package "net-firewall/shorewall"

execute "shorewall-restart" do
  command "/sbin/shorewall restart"
  action :nothing
end

directory "/etc/shorewall" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall/shorewall.conf" do
  source "ipv4/shorewall.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, "execute[shorewall-restart]"
end

%w(
  hosts
  interfaces
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall/#{t}" do
    source "ipv4/#{t}"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, "execute[shorewall-restart]"
  end
end

service "shorewall" do
  action [:enable, :start]
end
