include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_spamd] = "/usr/bin/sa-check_spamd -H localhost -t 10 -w 5 -c 10"

# nagios service checks
default[:nagios][:services]["SPAMD"] = {
  :check_command => "check_nrpe!check_spamd",
}
