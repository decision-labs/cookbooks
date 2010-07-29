include_recipe "gitosis"
include_recipe "mysql::server"
include_recipe "nginx"
include_recipe "portage"
include_recipe "postfix::default"

portage_package_keywords "=www-apps/trac-0.12"
portage_package_keywords "=www-apps/trac-git-8215"
portage_package_keywords "=www-apps/trac-accountmanager-7737"

portage_package_use "www-apps/trac" do
  use %w(mysql)
end

package "www-apps/trac"
package "www-apps/trac-git"
package "www-apps/trac-accountmanager"

group "git" do
  members "tracd"
  append true
end

directory "/etc/trac" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/trac/trac.ini" do
  source "trac.ini.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/trac/initial.sql" do
  source "initial.sql.erb"
  owner "root"
  group "root"
  mode "0600"
end

cookbook_file "/etc/init.d/tracd" do
  source "tracd.initd"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/conf.d/tracd" do
  source "tracd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "tracd" do
  action [ :enable, :start ]
end

template "/etc/nginx/servers/trac.conf" do
  source "trac.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

include_recipe "trac::environments"
