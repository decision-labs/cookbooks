include_recipe "portage"

portage_package_keywords "=net-misc/rabbitmq-server-2.1.0"

package "net-misc/rabbitmq-server"

service "rabbitmq" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
