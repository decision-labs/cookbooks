package "net-firewall/shorewall-shell"

node[:shorewall][:rules] = {}

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

cookbook_file "/etc/shorewall/shorewall.conf" do
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

%w(zones interfaces policy params rules).each do |t|
  template "/etc/shorewall/#{t}" do
    source "#{t}.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, resources(:execute => "shorewall-restart"), :delayed
  end
end

# XXX: we do not include shorewall6 by default for now, because the
# shorewall-perl compiler (which is required for shorewall6) does not work
# without multiport match support in the kernel, which is missing on almost all
# machines.

#if node[:ipv6_enabled]
#  include_recipe "shorewall::ipv6"
#end
