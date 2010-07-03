portage_package_keywords "=app-admin/chef-server-webui-0.9.6"

package "app-admin/chef-server-webui" do
  action :upgrade
end

template "/etc/chef/webui.rb" do
  source "webui.rb.erb"
  owner "root"
  group "root"
  mode "0600"
end

service "chef-server-webui" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "app-admin/chef-server-webui", :template => "/etc/chef/webui.rb")
end
