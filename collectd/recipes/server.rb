include_recipe "portage"

portage_package_keywords "~app-admin/collectd-4.10.1"

package "app-admin/collectd"

service "collectd" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/collectd.conf" do
  source "collectd.conf.erb"
  owner "root"
  group "root"
  mode "0640"
end

directory "/etc/collect.d" do
  owner "root"
  group "root"
  mode "0750"
end
