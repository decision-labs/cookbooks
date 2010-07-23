node[:php][:fpm][:socket_user] = "nginx"
node[:php][:fpm][:socket_group] = "nginx"
node[:php][:fpm][:user] = "nginx"
node[:php][:fpm][:group] = "nginx"

include_recipe "nginx"
include_recipe "php"

cookbook_file "/etc/nginx/php.conf" do
  source "php.conf"
  owner "root"
  group "root"
  mode "0644"
end
