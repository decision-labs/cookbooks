package "net-firewall/shorewall-shell"

service "shorewall" do
  action :enable
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
    notifies :restart, resources(:service => "shorewall"), :delayed
  end
end
