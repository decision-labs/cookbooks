include_recipe "portage"
include_recipe "chef::overlay"

portage_package_keywords "=net-misc/rabbitmq-server-1.7.2-r2"

package "net-misc/rabbitmq-server"

service "rabbitmq" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "net-misc/rabbitmq-server")
end
