include_recipe "git"

execute "git init" do
  not_if "test -d /etc/.git"
  cwd "/etc"
end

directory "/etc/.git" do
  owner "root"
  group "root"
  mode "0700"
end

file "/etc/.gitignore" do
  content <<-EOS
*~
adjtime
config-archive
hosts.deny*
ld.so.cache
mtab
resolv*
EOS
  owner "root"
  group "root"
  mode "0644"
end

bash "commit changes to /etc" do
  code <<-EOS
cd /etc
git add -A .
git commit -m 'automatic commit during chef-client run'
git gc
EOS
  not_if 'test "$(GIT_DIR=/etc/.git GIT_WORK_TREE=/etc git status --porcelain)" = ""'
end

nodes = search(:node, "ipaddress:[* TO *]", "hostname asc")
host_node = nil

if node[:virtualization][:host]
  host_node = search(:node, "fqdn:#{node[:virtualization][:host]}").first
end

template "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  source "hosts.erb"
  variables :nodes => nodes, :host_node => host_node
end

file "/etc/resolv.conf" do
  owner "root"
  group "root"
  mode "0644"
  content "nameserver 188.40.80.108\nnameserver 79.140.39.11\n"
end

if node[:virtualization][:role] == "guest" and node[:virtualization][:emulator] = "vserver"
  execute "reload sysctl settings" do
    command "/bin/true"
    action :nothing
  end
else
  execute "reload sysctl settings" do
    command "sysctl -p /etc/sysctl.conf"
    action :nothing
  end
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf.erb"
  notifies :run, resources(:execute => "reload sysctl settings")
end

if node[:virtualization][:emulator] == "vserver" and node[:virtualization][:role] == "guest"
  execute "reload-init" do
    command "/bin/true"
    action :nothing
  end
else
  execute "reload-init" do
    command "/sbin/telinit q"
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

%w(ZOMBIES PROCS LOAD DISKS SWAP).each do |t|
  untag("nagios-#{t}")
end

nagios_plugin "raid" do
  source "check_raid"
end

begin
  include_recipe "base::#{node[:platform]}"
rescue
  raise "The base module has not been ported to your platform (#{node[:platform]})"
end
