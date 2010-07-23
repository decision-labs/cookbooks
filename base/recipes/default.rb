nodes = search(:node, "ipaddress:[* TO *]")

template "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  source "hosts.erb"
  variables :nodes => nodes
end

file "/etc/resolv.conf" do
  owner "root"
  group "root"
  mode "0644"
  content "nameserver 188.40.80.108\nnameserver 79.140.39.11\n"
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf.erb"
end

case node[:virtualization][:role]
when "host"
  execute "reload-init" do
    command "/sbin/telinit q"
    action :nothing
  end
else
  execute "reload-init" do
    command "/bin/true"
    action :nothing
  end
end

template "/etc/inittab" do
  owner "root"
  group "root"
  mode "0644"
  source "inittab.erb"
  notifies :run, resources(:execute => "reload-init")
  backup 0
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
end

execute "locale-gen" do
  command "/usr/sbin/locale-gen"
  action :nothing
end

template "/etc/locale.gen" do
  # TODO: make it configurable
  owner "root"
  group "root"
  mode "0644"
  source "locale.gen.erb"
  notifies :run, resources(:execute => "locale-gen")
end

%w(/root /root/.ssh).each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0700"
  end
end

link "/dev/fd" do
  to "/proc/self/fd"
end

link "/dev/stdin" do
  to "/dev/fd/0"
end

link "/dev/stdout" do
  to "/dev/fd/1"
end

link "/dev/stderr" do
  to "/dev/fd/2"
end

%w(ZOMBIES PROCS).each do |t| tag("nagios-#{t}") end

if node[:virtualization][:role] == "host"
  %w(LOAD DISKS SWAP).each do |t| tag("nagios-#{t}") end
end

case node[:platform]
when "gentoo"
  include_recipe "base::gentoo"
else
  raise "The base module has not been ported to your platform (#{node[:platform]})"
end
