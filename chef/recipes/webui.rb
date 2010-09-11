include_recipe "nginx"
include_recipe "openssl"
include_recipe "portage"

portage_package_keywords "=app-admin/chef-server-webui-0.9.6"

package "app-admin/chef-server-webui" do
  action :upgrade
end

service "chef-server-webui" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/chef/webui.rb" do
  source "webui.rb.erb"
  owner "chef"
  group "chef"
  mode "0600"
  notifies :restart, resources(:service => "chef-server-webui")
end

ssl_certificate "/etc/ssl/nginx/#{node[:fqdn]}" do
  cn node[:fqdn]
end

nginx_server "chef-server-webui" do
  source "chef-server-webui.nginx.erb"
end
