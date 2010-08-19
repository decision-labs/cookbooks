# this should be overriden globally or per-role
default[:contacts][:hostmaster] = "root@#{node[:fqdn]}"

# time zone
default[:timezone] = "Europe/Berlin"

# ohai does not detect Linux-VServer
if File.exists?("/proc/self/vinfo")
  set[:virtualization][:emulator] = "vserver"
  if File.exists?("/proc/virtual")
    set[:virtualization][:role] = "host"
  else
    set[:virtualization][:role] = "guest"
  end
end

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
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
  ip6addrs = node[:network][:interfaces][network[:default_interface]][:addresses].reject { |k,v| v[:family] != "inet6" }
  begin
    default[:ip6address] = ip6addrs[0][0]
  rescue
    # do nothing
  end
end
