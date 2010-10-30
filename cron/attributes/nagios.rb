# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_cron] = "/usr/lib/nagios/plugins/check_cron"

# nagios service checks
default[:nagios][:services]["CRON"] = {
  :check_command => "check_nrpe!check_cron",
}
