include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_syslog] = "/usr/lib/nagios/plugins/check_pidfile /var/run/syslog-ng.pid /usr/sbin/syslog-ng"

# nagios service checks
default[:nagios][:services]["SYSLOG"] = {
  :check_command => "check_nrpe!check_syslog",
}
