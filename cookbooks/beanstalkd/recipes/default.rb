package "app-misc/beanstalkd"

service "beanstalkd" do
  action :enable
end

template "/etc/conf.d/beanstalkd" do
  source "beanstalkd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[beanstalkd]"
end

if tagged?("nagios-client")
  include_recipe "beanstalkd::nagios"

  nrpe_command "check_beanstalkd" do
    command "/usr/lib/nagios/plugins/check_beanstalkd -S localhost:11300"
  end

  nagios_service "BEANSTALKD" do
    check_command "check_nrpe!check_beanstalkd"
  end
end
