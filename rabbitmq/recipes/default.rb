include_recipe "portage"

portage_package_keywords "=net-misc/rabbitmq-server-1.8.0"

package "net-misc/rabbitmq-server" do
  action :upgrade
end

service "rabbitmq" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "net-misc/rabbitmq-server")
end
