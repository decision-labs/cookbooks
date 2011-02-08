tag("ipsec")

include_recipe "portage"
include_recipe "openssl"

portage_package_keywords "=net-firewall/ipsec-tools-0.7.3-r1"

package "net-firewall/ipsec-tools"

service "racoon" do
  action :enable
end

cookbook_file "/etc/conf.d/racoon" do
  source "racoon.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[racoon]"
end

nodes = search(:node, "tags:ipsec AND ipv6_enabled:true AND NOT fqdn:#{node[:fqdn]}")

template "/etc/ipsec.conf" do
  source "ipsec.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  variables :nodes => nodes
  notifies :restart, "service[racoon]"
end

directory "/etc/ssl/racoon" do
  owner "root"
  group "root"
  mode "0750"
  recursive true
end

ssl_ca "/etc/ssl/racoon/ca" do
  symlink true
  notifies :restart, "service[racoon]"
end

ssl_certificate "/etc/ssl/racoon/machine" do
  cn node[:fqdn]
  notifies :restart, "service[racoon]"
end

directory "/etc/racoon" do
  owner "root"
  group "root"
  mode "0750"
end

template "/etc/racoon/racoon.conf" do
  source "racoon.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  variables :nodes => nodes
  notifies :restart, "service[racoon]"
end
