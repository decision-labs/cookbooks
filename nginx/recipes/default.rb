include_recipe "portage"

portage_package_keywords "app-vim/nginx-syntax"
portage_package_keywords ">=www-servers/nginx-0.8.34-r1"

nginx_default_use_flags = %w(
  -ipv6
  -nginx_modules_http_browser
  -nginx_modules_http_empty_gif
  -nginx_modules_http_geo
  -nginx_modules_http_memcached
  -nginx_modules_http_ssi
  -nginx_modules_http_userid
  aio
  nginx_modules_http_realip
  nginx_modules_http_stub_status
)

portage_package_use "www-servers/nginx" do
  use(nginx_default_use_flags + node[:nginx][:use_flags])
end

group "nginx" do
  gid 82
end

user "nginx" do
  uid 82
  gid 82
  home "/dev/null"
  shell "/sbin/nologin"
end

package "www-servers/nginx"

directory "/etc/nginx" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/fastcgi.conf" do
  source "fastcgi.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

file "/etc/nginx/fastcgi_params" do
  action :delete
end

directory "/etc/nginx/servers" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/nginx/servers/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/nginx/servers/status.conf" do
  source "status.conf"
  owner "root"
  group "root"
  mode "0644"
end

service "nginx" do
  action [ :enable, :start ]
end
