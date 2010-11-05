include_attribute "nagios"
include_attribute "postfix::default"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_postfix] = "/usr/lib/nagios/plugins/check_pidfile /var/spool/postfix/pid/master.pid postfix/master"
# XXX: node[:postfix][:relayhost] is not available here if overridden.
#default[:nagios][:nrpe][:commands][:check_postfix_satelite] = "/usr/lib/nagios/plugins/check_smtp -H #{node[:postfix][:relayhost]} -t 3 -C 'MAIL FROM: <root@#{node[:fqdn]}>' -R '250 2.1.0 Ok' -C 'RCPT TO: <unhollow@gmail.com>' -R '250 2.1.5 Ok'"
default[:nagios][:nrpe][:commands][:check_postfix_tls] = "/usr/lib/nagios/plugins/check_ssl_cert -H localhost -n #{node[:fqdn]} -P smtp -p 25 -w 21 -c 7"
default[:nagios][:nrpe][:commands][:check_postgrey] = "/usr/lib/nagios/plugins/check_pidfile /var/run/postgrey.pid /usr/sbin/postgrey"
default[:nagios][:nrpe][:commands][:check_smtp] = "/usr/lib/nagios/plugins/check_smtp -H localhost -t 3"


# nagios service checks
default[:nagios][:services]["POSTFIX"] = {
  :check_command => "check_nrpe!check_postfix",
}

default[:nagios][:services]["POSTFIX-SATELITE"] = {
  :check_command => "check_nrpe!check_postfix_satelite",
}

default[:nagios][:services]["POSTFIX-TLS"] = {
  :check_command => "check_nrpe!check_postfix_tls",
  :dependencies => %w(POSTFIX),
}

default[:nagios][:services]["POSTGREY"] = {
  :check_command => "check_nrpe!check_postgrey",
}

default[:nagios][:services]["SMTP"] = {
  :check_command => "check_nrpe!check_smtp",
  :dependencies => %w(POSTFIX),
}
