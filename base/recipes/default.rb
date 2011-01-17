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

# reset all attributes to make sure cruft is being deleted on chef-client run
node.default[:nagios][:services] = {}

nrpe_command "check_zombie_procs" do
  command "/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z"
end

nrpe_command "check_total_procs" do
  command "/usr/lib/nagios/plugins/check_procs -w 200 -c 1000"
end

nagios_service "PING" do
  check_command "check_ping!100.0,20%!500.0,60%"
end

nagios_service "ZOMBIES" do
  check_command "check_nrpe!check_zombie_procs"
end

nagios_service "PROCS" do
  check_command "check_nrpe!check_total_procs"
end

if node[:virtualization][:role] == "host"
  nagios_plugin "raid" do
    source "check_raid"
  end

  nrpe_command "check_load" do
    command "/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20"
  end

  nagios_service "LOAD" do
    check_command "check_nrpe!check_load"
  end

  nrpe_command "check_raid" do
    command "/usr/lib/nagios/plugins/check_raid"
  end

  nagios_service "RAID" do
    check_command "check_nrpe!check_raid"
  end

  nrpe_command "check_disks" do
    command "/usr/lib/nagios/plugins/check_disk -w 10% -c 5%"
  end

  nagios_service "DISKS" do
    check_command "check_nrpe!check_disks"
    notification_interval 15
  end

  nagios_service_escalation "DISKS" do
    notification_interval 15
  end

  nrpe_command "check_swap" do
    command "/usr/lib/nagios/plugins/check_swap -w 75% -c 50%"
  end

  nagios_service "SWAP" do
    check_command "check_nrpe!check_swap"
    notification_interval 180
  end
end

begin
  include_recipe "base::#{node[:platform]}"
rescue
  raise "The base module has not been ported to your platform (#{node[:platform]})"
end
