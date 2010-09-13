include_recipe "portage"

cookbook_file "/etc/portage/package.keywords/chef" do
  source "chef.keywords"
  owner "root"
  group "root"
  mode "0644"
end

package "app-admin/chef" do
  action :upgrade
end

if node.run_list?("recipe[chef::server]")
  node[:chef][:client][:server_url] = "http://127.0.0.1:4000"
else
  file "/etc/chef/validation.pem" do
    action :delete
    backup false
  end
end

cookbook_file "/etc/logrotate.d/chef" do
  source "chef.logrotate"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "chef-client" do
  supports :status => true
  action [ :disable, :stop ]
end

chef_server = tagged?("chef-server")

directory "/var/lib/chef/cache" do
  owner "root"
  group chef_server ? "chef" : "root"
  mode "0770"
end

file "/var/log/chef/client.log" do
  owner "root"
  group "root"
  mode "0600"
end
