package "app-misc/beanstalkd"

service "beanstalkd" do
  action :enable
end

template "/etc/conf.d/beanstalkd" do
  source "beanstalkd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "beanstalkd")
end
