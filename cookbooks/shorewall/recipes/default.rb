# reset all attributes to make sure cruft is being deleted on chef-client run
node[:shorewall][:hosts] = {}
node[:shorewall6][:hosts] = {}
node[:shorewall][:interfaces] = {}
node[:shorewall6][:interfaces] = {}
node[:shorewall][:policies] = {}
node[:shorewall6][:policies] = {}
node[:shorewall][:rules] = {}
node[:shorewall6][:rules] = {}
node[:shorewall][:tunnels] = {}
node[:shorewall6][:tunnels] = {}
node[:shorewall][:zones] = {}
node[:shorewall6][:zones] = {}

include_recipe "shorewall::rules"

# pkgsync rules
if tagged?("pkgsync-client")
  search(:node, "tags:pkgsync-master").each do |n|
    shorewall_rule "pkgsync-master@#{n[:fqdn]}" do
      source "net:#{n[:ipaddress]}"
      dest "$FW:#{node[:ipaddress]}"
      destport "rsync"
    end

    if n[:ip6address]
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
  shorewall_rule "nagios-master@#{n[:fqdn]}" do
    source "net:#{n[:ipaddress]}"
    destport "4949,5666"
  end

  if n[:ip6address]
    shorewall6_rule "nagios-master@#{n[:fqdn]}" do
      source "net:<#{n[:ip6address]}>"
      destport "5666"
    end
  end
end

# munin rules
search(:node, "tags:munin-master").each do |n|
  shorewall_rule "munin-master@#{n[:fqdn]}" do
    source "net:#{n[:ipaddress]}"
    destport "4949"
  end

  if n[:ip6address]
    shorewall6_rule "munin-master@#{n[:fqdn]}" do
      source "net:<#{n[:ip6address]}>"
      destport "4949"
    end
  end
end

include_recipe "shorewall::ipv4"

if node[:ipv6_enabled]
  include_recipe "shorewall::ipv6"
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
  servicegroups "system"
end

nagios_service_escalation "CONNTRACK" do
  notification_interval 15
end
