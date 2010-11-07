include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_couchdb] = "/usr/lib/nagios/plugins/check_http -H localhost -p 5984 -s couchdb"

# nagios service checks
default[:nagios][:services]["COUCHDB"] = {
  :check_command => "check_nrpe!check_couchdb",
}
