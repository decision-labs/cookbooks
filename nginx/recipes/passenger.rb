node[:nginx][:use_flags].push("nginx_modules_http_passenger").sort!.uniq!

include_recipe "nginx"

nginx_module "passenger" do
  template "passenger.conf.erb"
end
