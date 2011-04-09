unless node[:skip][:munin_node]
  tag("munin-node")

  include_recipe "munin"

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
    notifies :restart, "service[munin-node]"
  end

  file "/etc/munin/plugin-conf.d/munin-node" do
    content ""
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[munin-node]"
  end

  service "munin-node" do
    action [:enable, :start]
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

  nagios_service "MUNIN-NODE" do
    check_command "check_munin_node"
  end
end
