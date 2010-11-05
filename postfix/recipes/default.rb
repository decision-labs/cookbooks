include_recipe "portage"

portage_package_use "mail-mta/postfix" do
  use node[:postfix][:use_flags].sort.uniq
end

package "mail-mta/postfix"

group "postfix" do
  gid 207
end

group "postdrop" do
  gid 208
end

user "postfix" do
  uid 207
  gid 207
  home "/var/spool/postfix"
end

group "mail" do
  gid 12
  members %w(postfix)
  append true
end

user "mail" do
  uid 8
  gid 12
  home "/var/spool/mail"
end

directory "/etc/mail" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/mail/aliases" do
  source "aliases.erb"
  owner "root"
  group "root"
  mode "0644"
end

directory "/etc/postfix" do
  owner "root"
  group "root"
  mode "0755"
end

service "postfix" do
  supports :status => true
  action :enable
end

ipv6_str = node[:ipv6_enabled] ? ", ipv6" : ""

postconf "base" do
  set :myhostname => node[:fqdn],
      :mydomain => node[:domain],
      :mynetworks_style => "host",
      :inet_protocols => "ipv4#{ipv6_str}"
end

postmaster "smtp" do
  stype "inet"
  priv "n"
  command "smtpd"
end

execute "newaliases" do
  command "/usr/bin/newaliases"
  not_if do FileUtils.uptodate?("/etc/mail/aliases.db", %w(/etc/mail/aliases)) end
end

# nagios service checks
if tagged?("nagios-client")
  node.default[:nagios][:services]["POSTFIX"][:enabled] = true
  node.default[:nagios][:services]["SMTP"][:enabled] = true
end
