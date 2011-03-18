# this nodes chef environment
default[:chef_environment] = "production"

# cluster support
default[:cluster][:name] = "default"

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
  ip6addrs = node[:network][:interfaces][node[:network][:default_interface]][:addresses].select do |k,v|
    v[:family] == "inet6" and not v[:scope] == "Link"
  end

  begin
    default[:ip6address] = ip6addrs[0][0]
    set[:ip6prefixlen] = node[:network][:interfaces][node[:network][:default_interface]][:addresses][node[:ip6address]][:prefixlen]
  rescue
    default[:ip6address] = nil
    set[:ip6prefixlen] = nil
  end
end

# try to figure out the private IP address if it exists
local_interface = if node[:network][:interfaces][:eth1]
                    :eth1
                  else
                    :eth0
                  end

require 'ipaddr'

def private?(ip)
  ip = IPAddr.new(ip)
  return false unless ip.ipv4?

  [
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16")
  ].each do |ipr|
    return true if ipr.include?(ip)
  end

  return false
end

begin
  out = %x(ip addr show dev #{local_interface}|sed 's/^\\s\\+inet \\([0-9\\.]\\+\\).*/\\1/;tn;d;:n')
  local_addrs = out.split.select do |v|
    private?(v)
  end
  set[:local_ipaddress] = local_addrs[0]
rescue
  set[:local_ipaddress] = nil
end
