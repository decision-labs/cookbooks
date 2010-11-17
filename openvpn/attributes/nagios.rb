include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_openvpn] = "/usr/lib/nagios/plugins/check_pidfile /var/run/openvpn.pid /usr/sbin/openvpn"

# nagios service checks
default[:nagios][:services]["OPENVPN"] = {
  :check_command => "check_nrpe!check_openvpn",
}
