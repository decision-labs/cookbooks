package "dev-perl/Nagios-Plugin-Beanstalk" do
  action :purge
end

package "dev-python/beanstalkc"

nagios_plugin "beanstalkd" do
  source "check_beanstalkd"
end
