default[:nagios][:from_address] = "nagios@#{node[:fqdn]}"

default[:mysql][:nagios] = Mash.new

# global service checks
default[:mysql][:nagios][:uptime] = {
  :mode => "uptime",
  :warning => "120:",
  :critical => "0:",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:ctime] = {
  :mode => "connection-time",
  :warning => "0.1",
  :critical => "0.3",
  :normal_check_interval => "1"
}

default[:mysql][:nagios][:tchit] = {
  :mode => "threadcache-hitrate",
  :warning => "90:",
  :critical => "80:",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:qchit] = {
  :mode => "qcache-hitrate",
  :warning => "90:",
  :critical => "80:",
  :silent => true,
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:qclow] = {
  :mode => "qcache-lowmem-prunes",
  :warning => "1",
  :critical => "10",
  :silent => true,
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:slow] = {
  :mode => "slow-queries",
  :warning => "0.1",
  :critical => "1",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:long] = {
  :mode => "long-running-procs",
  :warning => "10",
  :critical => "20",
}

default[:mysql][:nagios][:tabhit] = {
  :mode => "tablecache-hitrate",
  :warning => "99:",
  :critical => "95:",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:lock] = {
  :mode => "table-lock-contention",
  :warning => "1",
  :critical => "2",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:index] = {
  :mode => "index-usage",
  :warning => "90:",
  :critical => "80:",
  :silent => true,
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:tmptab] = {
  :mode => "tmp-disk-tables",
  :warning => "25",
  :critical => "50",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

# MyISAM specific checks
default[:mysql][:nagios][:kchit] = {
  :mode => "keycache-hitrate",
  :warning => "99:",
  :critical => "95:",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

# InnoDB specific checks
default[:mysql][:nagios][:bphit] = {
  :mode => "bufferpool-hitrate",
  :warning => "99:",
  :critical => "95:",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:bpwait] = {
  :mode => "bufferpool-wait-free",
  :warning => "1",
  :critical => "10",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

default[:mysql][:nagios][:logwait] = {
  :mode => "log-waits",
  :warning => "1",
  :critical => "10",
  :notification_interval => "1440",
  :normal_check_interval => "60"
}

# replication checks
default[:mysql][:nagios][:slavelag] = {
  :mode => "slave-lag",
  :warning => "10",
  :critical => "20",
  :enabled => false
}

default[:mysql][:nagios][:slaveio] = {
  :mode => "slave-io-running",
  :warning => "0",
  :critical => "0",
  :enabled => false
}

default[:mysql][:nagios][:slavesql] = {
  :mode => "slave-sql-running",
  :warning => "0",
  :critical => "0",
  :enabled => false
}

default[:mysql][:nagios].each do |name, params|
  params[:enabled] = true unless params.has_key?(:enabled)
  params[:silent] = false unless params.has_key?(:silent)
  params[:normal_check_interval] = "5" unless params.has_key?(:normal_check_interval)
  params[:notification_interval] = "60" unless params.has_key?(:notification_interval)
end
