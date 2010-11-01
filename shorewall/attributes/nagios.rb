include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_conntrack] = "/usr/lib/nagios/plugins/check_conntrack 75 90"

# nagios service checks
default[:nagios][:services]["CONNTRACK"] = {
  :check_command => "check_nrpe!check_conntrack",
  :notification_interval => 15,
  :escalations => [{:notification_interval => 15}],
}
