tag("nagios-master")

include_recipe "portage"
include_recipe "apache::fastcgi"
include_recipe "apache::openid"
include_recipe "apache::php"

portage_package_use "net-analyzer/nagios-plugins" do
  use %w(ldap mysql nagios-dns nagios-ntp nagios-ping nagios-ssh postgres)
end

portage_package_use "net-analyzer/nagios-core" do
  use %w(apache2)
end

package "net-analyzer/nagios"

service "nagios" do
  supports :status => true
  action :enable
end

directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

directory "/var/nagios/rw" do
  owner "nagios"
  group "apache"
  mode "6755"
end

file "/var/nagios/rw/nagios.cmd" do
  owner "nagios"
  group "apache"
  mode "0660"
end

# nagios config
%w(nagios cgi resource).each do |f|
  nagios_conf f do
    subdir false
  end
end

%w(localhost printer switch windows).each do |f|
  nagios_conf f do
    action :delete
  end
end

hosts = search(:node, "tags:nagios-client")
roles = []
hostgroups = {}

search(:role, "*:*") do |r|
  roles << r
  hostgroups[r.name] = []
  search(:node, "tags:nagios-client AND role:#{r.name}") do |n|
    hostgroups[r.name] << n[:fqdn]
  end
end

mysql_nodes = search(:node, "tags:nagios-MYSQL")

%w(templates timeperiods commands contacts services hosts hostgroups).each do |f|
  nagios_conf f do
    variables :hosts => hosts,
              :roles => roles,
              :hostgroups => hostgroups,
              :mysql_nodes => mysql_nodes
  end
end

# apache specifics
group "nagios" do
  members %w(apache)
  append true
end

users = search(:users, "(groups:hostmaster OR groups:nagiosadmin) AND password:[* TO *]")

template "/etc/nagios/users" do
  source "users.erb"
  owner "root"
  group "apache"
  mode "0640"
  variables :users => users
end

node[:apache][:default_redirect] = "https://#{node[:fqdn]}"

apache_vhost "nagios" do
  template "nagios.vhost.conf.erb"
end

file "/var/www/localhost/htdocs/index.php" do
  content '<?php header("Location: /nagios/"); ?>\n'
  owner "root"
  group "root"
  mode "0644"
end
