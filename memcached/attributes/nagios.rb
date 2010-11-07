include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_memcached] = "/usr/bin/check_memcached"

# nagios service checks
default[:nagios][:services]["MEMCACHED"] = {
  :check_command => "check_nrpe!check_memcached",
}
