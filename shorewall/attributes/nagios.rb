# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_conntrack] = "/usr/lib/nagios/plugins/check_conntrack 75 90"

# nagios service checks
default[:nagios][:services]["CONNTRACK"] = {
  :check_command => "check_nrpe!check_conntrack"
}
