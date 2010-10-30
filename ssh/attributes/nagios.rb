# nagios service checks
default[:nagios][:services]["SSH"] = {
  :check_command => "check_ssh!22"
}
