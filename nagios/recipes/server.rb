tag("nagios-master")

include_recipe "portage"
include_recipe "apache::php"

portage_package_use "net-analyzer/nagios-plugins" do
  use %w(ldap mysql nagios-dns nagios-ntp nagios-ping nagios-ssh postgres)
end

portage_package_keywords "~net-analyzer/nagios-3.2.3"
portage_package_keywords "~net-analyzer/nagios-core-3.2.3"

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

template "/usr/lib/nagios/plugins/notify" do
  source "notify.sh"
  owner "root"
  group "nagios"
  mode "0750"
end

# retrieve data from the search index
contacts = search(:users, "tags:hostmaster OR tags:nagios").sort { |a,b| a[:id] <=> b[:id] }
hostmasters = search(:users, "tags:hostmaster").sort { |a,b| a[:id] <=> b[:id] }

hosts = search(:node, "tags:nagios-client").sort { |a,b| a[:fqdn] <=> b[:fqdn] }
roles = search(:role, "NOT name:base").sort { |a,b| a.name <=> b.name }
hostgroups = {}

roles.each do |role|
  hostgroups[role.name] = []
end

hosts.each do |host|
  host[:roles] ||= []
  host[:roles].each do |role|
    hostgroups[role] ||= []
    hostgroups[role] << host[:fqdn] unless role == "base"
  end
end

# remove sample objects
%w(hosts localhost printer services switch windows).each do |f|
  nagios_conf f do
    action :delete
  end
end

# nagios base config
%w(nagios resource).each do |f|
  nagios_conf f do
    subdir false
  end
end

nagios_conf "cgi" do
  subdir false
  variables :hostmasters => hostmasters
end

# create nagios objects
%w(templates commands).each do |f|
  nagios_conf f
end

nagios_conf "contacts" do
  variables :contacts => contacts,
            :hostmasters => hostmasters
end

nagios_conf "timeperiods" do
  variables :contacts => contacts
end

nagios_conf "hostgroups" do
  variables :roles => roles, :hostgroups => hostgroups
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

users = search(:users, "(tags:hostmaster OR tags:nagios) AND password:[* TO *]", "id asc")

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
