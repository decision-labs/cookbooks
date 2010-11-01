include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_zombie_procs] = "/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z"
default[:nagios][:nrpe][:commands][:check_total_procs] = "/usr/lib/nagios/plugins/check_procs -w 200 -c 1000"
default[:nagios][:nrpe][:commands][:check_load] = "/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20"
default[:nagios][:nrpe][:commands][:check_disks] = "/usr/lib/nagios/plugins/check_disk -w 10% -c 5%"
default[:nagios][:nrpe][:commands][:check_swap] = "/usr/lib/nagios/plugins/check_swap -w 75% -c 50%"

# nagios service checks
default[:nagios][:services]["PING"] = {
  :check_command => "check_ping!100.0,20%!500.0,60%",
  :enabled => true,
}

default[:nagios][:services]["ZOMBIES"] = {
  :check_command => "check_nrpe!check_zombie_procs",
  :enabled => true,
}

default[:nagios][:services]["PROCS"] = {
  :check_command => "check_nrpe!check_total_procs",
  :enabled => true,
}

if node[:virtualization][:role] == "host"
  default[:nagios][:services]["LOAD"] = {
    :check_command => "check_nrpe!check_load",
    :enabled => true,
  }

  default[:nagios][:services]["DISKS"] = {
    :check_command => "check_nrpe!check_disks",
    :notification_interval => 15,
    :enabled => true,
    :escalations => [{:notification_interval => 15}],
  }

  default[:nagios][:services]["SWAP"] = {
    :check_command => "check_nrpe!check_swap",
    :notification_interval => 180,
    :enabled => true,
  }
end
