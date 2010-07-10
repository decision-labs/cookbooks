include_recipe "portage"
include_recipe "apache::fastcgi"
include_recipe "apache::openid"

node[:php][:fpm][:socket_user] = "apache"
node[:php][:fpm][:socket_group] = "apache"
node[:php][:fpm][:user] = "apache"
node[:php][:fpm][:group] = "apache"

include_recipe "php"

nodes = search(:node, "hostname:[* TO *] AND role:base")
nagiosadmins = search(:users, "(groups:hostmaster OR groups:nagiosadmin) AND password:[* TO *]")

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

%w(templates timeperiods commands contacts services).each do |f|
  nagios_conf f
end

nagios_conf "hosts" do
  variables :nodes => nodes
end

group "nagios" do
  members %w(apache)
  append true
end

template "/etc/nagios/users" do
  source "users.erb"
  owner "root"
  group "apache"
  mode "0640"
  variables :users => nagiosadmins
end

template "/etc/apache2/vhosts.d/00-default.conf" do
  source "nagios.vhost.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "apache2"), :delayed
end

file "/var/www/localhost/htdocs/index.php" do
  content '<?php header("Location: /nagios/"); ?>\n'
  owner "root"
  group "root"
  mode "0644"
end
