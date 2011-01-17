package "net-firewall/shorewall" do
  action :remove
end

if node[:shorewall][:perl]
  package "net-firewall/shorewall-perl"
else
  package "net-firewall/shorewall-shell"
end

# reset all attributes to make sure cruft is being deleted on chef-client run
node[:shorewall][:interfaces] = {}
node[:shorewall][:notrack] = {}
node[:shorewall][:policies] = {}
node[:shorewall][:rules] = {}
node[:shorewall][:tunnels] = {}
node[:shorewall][:zones] = {}

service "shorewall" do
  supports :restart => false, :stop => false
  action :enable
end

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
  source "shorewall.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, resources(:execute => "shorewall-restart"), :delayed
end

include_recipe "shorewall::rules"

# pkgsync rules
if tagged?("pkgsync-client")
  search(:node, "tags:pkgsync-master").each do |n|
    shorewall_rule "pkgsync-master@#{n[:fqdn]}" do
      source "net:#{n[:ipaddress]}"
      dest "$FW:#{node[:ipaddress]}"
      destport "rsync"
    end
  end
end

# nagios rules
search(:node, "tags:nagios-master").each do |n|
  shorewall_rule "nagios-master@#{n[:fqdn]}" do
    source "net:#{n[:ipaddress]}"
    destport "5666"
  end
end

# munin rules
search(:node, "tags:munin-master").each do |n|
  shorewall_rule "munin-master@#{n[:fqdn]}" do
    source "net:#{n[:ipaddress]}"
    destport "4949"
  end
end

%w(
  interfaces
  notrack
  params
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall/#{t}" do
    source "#{t}.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, resources(:execute => "shorewall-restart"), :delayed
  end
end

nagios_plugin "conntrack" do
  source "check_conntrack"
end

nrpe_command "check_conntrack" do
  command "/usr/lib/nagios/plugins/check_conntrack 75 90"
end

nagios_service "CONNTRACK" do
  check_command "check_nrpe!check_conntrack"
  notification_interval 15
end

nagios_service_escalation "CONNTRACK" do
  notification_interval 15
end

# XXX: we do not include shorewall6 by default for now, because the
# shorewall-perl compiler (which is required for shorewall6) does not work
# without multiport match support in the kernel, which is missing on almost all
# machines.

#if node[:ipv6_enabled]
#  include_recipe "shorewall::ipv6"
#end
