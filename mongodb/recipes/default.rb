include_recipe "portage"

portage_package_keywords "=dev-lang/spidermonkey-1.7.0-r1"
portage_package_keywords "=dev-db/mongodb-1.6.3"

package "dev-db/mongodb"

service "mongodb" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/conf.d/mongodb" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mongodb")
end
