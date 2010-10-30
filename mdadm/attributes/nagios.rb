# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_swraid] = "/usr/lib/nagios/plugins/check_swraid"

# nagios service checks
default[:nagios][:services]["SWRAID"] = {
  :check_command => "check_nrpe!check_swraid"
}
