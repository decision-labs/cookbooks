include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_beanstalkd] = "/usr/bin/check_beanstalkd -H localhost"

# nagios service checks
default[:nagios][:services]["BEANSTALKD"] = {
  :check_command => "check_nrpe!check_beanstalkd",
}
