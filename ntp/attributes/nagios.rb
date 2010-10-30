# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_time] = "/usr/lib/nagios/plugins/check_ntp_time -H ptbtime1.ptb.de"

# nagios service checks
default[:nagios][:services]["TIME"] = {
  :check_command => "check_nrpe!check_time"
}
