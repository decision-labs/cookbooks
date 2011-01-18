node.default[:php][:fpm][:pools]["default"][:socket_user] = "nginx"
node.default[:php][:fpm][:pools]["default"][:socket_group] = "nginx"
node.default[:php][:fpm][:pools]["default"][:user] = "nginx"
node.default[:php][:fpm][:pools]["default"][:group] = "nginx"

include_recipe "nginx"
include_recipe "php"

cookbook_file "/etc/nginx/php.conf" do
  source "php.conf"
  owner "root"
  group "root"
  mode "0644"
end
