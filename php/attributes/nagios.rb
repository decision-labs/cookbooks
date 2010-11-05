include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_php_fpm] = "/usr/lib/nagios/plugins/check_pidfile /var/run/php-fpm.pid /usr/bin/php-fpm"

# nagios service checks
default[:nagios][:services]["PHP-FPM"] = {
  :check_command => "check_nrpe!check_php_fpm",
}
