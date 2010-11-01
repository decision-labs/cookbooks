include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_monit] = "/usr/lib/nagios/plugins/check_pidfile /var/run/monit.pid /usr/bin/monit"

# nagios service checks
default[:nagios][:services]["MONIT"] = {
  :check_command => "check_nrpe!check_monit",
}
