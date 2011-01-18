tag("munin-node")

include_recipe "munin"

service "munin-node" do
  supports :status => true, :restart => true
  action :enable
end

directory "/etc/ssl/munin" do
  owner "root"
  group "root"
  mode "0755"
end

ssl_ca "/etc/ssl/munin/ca" do
  owner "munin"
  group "munin"
end

ssl_certificate "/etc/ssl/munin/node" do
  cn node[:fqdn]
  owner "munin"
  group "munin"
end

server_nodes = search(:node, "tags:munin-master")

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf"
  owner "root"
  group "root"
  mode "0644"
  variables :server_nodes => server_nodes
  notifies :restart, resources(:service => "munin-node")
end

file "/etc/munin/plugin-conf.d/munin-node" do
  content ""
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "munin-node")
end

base_plugins = %w(
  df
  processes
  load
  memory
)

if node[:virtualization][:role] == "host"
  base_plugins += %w(
    iostat
    forks
    vmstat
    entropy
    cpu
    open_files
    open_inodes
    swap
  )
end

base_plugins.each do |p|
  munin_plugin p
end
