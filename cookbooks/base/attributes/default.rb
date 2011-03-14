# this nodes chef environment
default[:chef_environment] = "production"

# this should be overriden globally or per-role
default[:contacts][:hostmaster] = "root@#{node[:fqdn]}"

# time zone
default[:timezone] = "Europe/Berlin"

# custom /etc/hosts entries
default[:base][:additional_hosts] = []

# ohai does not detect Linux-VServer
if File.exists?("/proc/self/vinfo")
  set[:virtualization][:emulator] = "vserver"
  if File.exists?("/proc/virtual")
    set[:virtualization][:role] = "host"
  else
    set[:virtualization][:role] = "guest"
  end
else
  set[:virtualization][:role] = "host"
end

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60

# IPv6 info (missing from ohai)
set[:ipv6_enabled] = false

begin
  set[:ipv6_enabled] = true if File.read("/proc/net/protocols").match(/TCPv6/)
rescue
  # do nothing
end

if node[:ipv6_enabled]
  ip6addrs = node[:network][:interfaces][node[:network][:default_interface]][:addresses].reject { |k,v| v[:family] != "inet6" }
  begin
    default[:ip6address] = ip6addrs[0][0]
    set[:ip6prefixlen] = node[:network][:interfaces][node[:network][:default_interface]][:addresses][node[:ip6address]][:prefixlen]
  rescue
    set[:ipv6_enabled] = false
  end
end

# cluster support
default[:cluster][:name] = "default"

# if eth1 exists assume it has the local network in this cluster
if node[:network][:interfaces][:eth1]
  begin
    set[:local_ipaddress] = node[:network][:interfaces][:eth1][:addresses].reject { |k,v| v[:family] != "inet" }[0][0]
  rescue
    set[:local_ipaddress] = nil
  end
else
  set[:local_ipaddress] = nil
end
