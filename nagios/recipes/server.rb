tag("nagios-master")

include_recipe "portage"
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

# nagios base config
%w(nagios cgi resource).each do |f|
  nagios_conf f do
    subdir false
  end
end

# remove sample objects
%w(localhost printer switch windows).each do |f|
  nagios_conf f do
    action :delete
  end
end

# build base objects
%w(templates timeperiods commands contacts).each do |f|
  nagios_conf f
end

# build host and service objects
hosts = search(:node, "tags:nagios-client")
roles = search(:role, "*:*")
hostgroups = {}

roles.each do |role|
  hostgroups[role.name] = []
end

hosts.each do |host|
  host[:roles] ||= []
  host[:roles].each do |role|
    hostgroups[role] << host[:fqdn]
  end
end

nagios_conf "hostgroups" do
  variables :roles => roles, :hostgroups => hostgroups
end

%w(services hosts).each do |f|
  nagios_conf f do
    action :delete
  end
end

hosts.each do |host|
  nagios_conf "host-#{host[:fqdn]}" do
    template "host.cfg.erb"
    variables :host => host
  end
end

# apache specifics
group "nagios" do
  members %w(apache)
  append true
end

users = search(:users, "(tags:hostmaster OR tags:nagiosadmin) AND password:[* TO *]")

template "/etc/nagios/users" do
  source "users.erb"
  owner "root"
  group "apache"
  mode "0640"
  variables :users => users
end

node[:apache][:default_redirect] = "https://#{node[:fqdn]}"

ssl_ca "/etc/ssl/apache2/ca"

ssl_certificate "/etc/ssl/apache2/server" do
  cn node[:fqdn]
end

apache_vhost "nagios" do
  template "nagios.vhost.conf.erb"
end

file "/var/www/localhost/htdocs/index.php" do
  content '<?php header("Location: /nagios/"); ?>\n'
  owner "root"
  group "root"
  mode "0644"
end
