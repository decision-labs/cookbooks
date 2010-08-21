package "net-firewall/shorewall6"

node[:shorewall][:rules6] = {}

service "shorewall6" do
  supports :restart => false, :stop => false
  action :enable
end

execute "shorewall6-restart" do
  command "/sbin/shorewall6 restart"
  action :nothing
end

directory "/etc/shorewall6" do
  owner "root"
  group "root"
  mode "0700"
end

cookbook_file "/etc/shorewall6/shorewall6.conf" do
  source "shorewall6.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, resources(:execute => "shorewall6-restart"), :delayed
end

include_recipe "shorewall::rules6"

# pkgsync rules
if tagged?("pkgsync-client")
  search(:node, "tags:pkgsync-master").each do |n|
    if n[:ipv6_enabled]
      shorewall6_rule "pkgsync-master@#{n[:fqdn]}" do
        source "net:<#{n[:ip6address]}>"
        dest "$FW:<#{node[:ip6address]}>"
        destport "rsync"
      end
    end
  end
end

# nagios rules
search(:node, "tags:nagios-master").each do |n|
  if n[:ipv6_enabled]
    shorewall6_rule "nagios-master@#{n[:fqdn]}" do
      source "net:<#{n[:ip6address]}>"
      destport "5666"
    end
  end
end

ipsec_enabled = tagged?("ipsec")
ipsec_nodes = search(:node, "tags:ipsec AND ipv6_enabled:true AND NOT fqdn:#{node[:fqdn]}")

%w(hosts zones interfaces tunnels policy params rules).each do |t|
  template "/etc/shorewall6/#{t}" do
    source "ipv6/#{t}.erb"
    owner "root"
    group "root"
    mode "0600"
    variables :ipsec_nodes => ipsec_nodes, :ipsec_enabled => ipsec_enabled
    notifies :run, resources(:execute => "shorewall6-restart"), :delayed
  end
end
