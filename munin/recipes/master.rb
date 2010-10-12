tag("munin-master")

include_recipe "munin"

package "media-fonts/dejavu"

directory "/etc/ssl/munin" do
  owner "root"
  group "root"
  mode "0755"
end

ssl_ca "/etc/ssl/munin/ca" do
  owner "munin"
  group "munin"
end

ssl_certificate "/etc/ssl/munin/master" do
  cn node[:fqdn]
  owner "munin"
  group "munin"
end

client_nodes = search(:node, "tags:munin-node")

template "/etc/munin/munin.conf" do
  source "munin.conf"
  owner "root"
  group "root"
  mode "0644"
  variables :client_nodes => client_nodes
end

cron "munin-cron" do
  command "/usr/bin/munin-cron"
  minute "*/5"
  user "munin"
end

munin_plugin "munin_update"
munin_plugin "munin_stats"
