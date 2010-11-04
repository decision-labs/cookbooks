include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_apache2] = "/usr/lib/nagios/plugins/check_apache2 -H localhost -p 8031 -u / -w 20 -c 3"

# nagios service checks
default[:nagios][:services]["APACHE2"] = {
  :check_command => "check_nrpe!check_apache2",
}
