include_attribute "nagios"

{ # name          command               warn crit check note period
  :ctime    => %w(connection-time       1    5    1     60   24x7),
  :tchit    => %w(threadcache-hitrate   90:  80:  60    1440 24x7),
  :qchit    => %w(qcache-hitrate        90:  80:  60    60   never),
  :qclow    => %w(qcache-lowmem-prunes  1    10   60    60   never),
  :slow     => %w(slow-queries          0.1  1    60    60   24x7),
  :long     => %w(long-running-procs    10   20   5     60   24x7),
  :tabhit   => %w(tablecache-hitrate    99:  95:  60    1440 24x7),
  :lock     => %w(table-lock-contention 1    2    60    60   24x7),
  :index    => %w(index-usage           90:  80:  60    60   never),
  :tmptab   => %w(tmp-disk-tables       25   50   60    1440 24x7),
  :kchit    => %w(keycache-hitrate      99:  95:  60    1440 24x7),
  :bphit    => %w(bufferpool-hitrate    99:  95:  60    1440 24x7),
  :bpwait   => %w(bufferpool-wait-free  1    10   60    1440 24x7),
  :logwait  => %w(log-waits             1    10   60    1440 24x7),
  :slaveio  => %w(slave-io-running      1    10   1     1440 24x7),
  :slavesql => %w(slave-sql-running     1    10   1     1440 24x7),
  :slavelag => %w(slave-lag             10   60   5     60   24x7),
}.each do |name, p|
  name = name.to_s
  command_name = "check_mysql_#{name}"

  default[:nagios][:nrpe][:commands][command_name] = "/usr/lib/nagios/plugins/check_mysql_health_wrapper --mode #{p[0]} --warning #{p[1]} --critical #{p[2]}"
  default[:nagios][:services]["MYSQL-#{name.upcase}"] = {
    :check_command => "check_nrpe!check_mysql_#{name}",
    :normal_check_interval => p[3],
    :notification_interval => p[4],
    :notification_period => p[5]
  }
end

# enable escalations for critical checks
default[:nagios][:services]["MYSQL-CTIME"][:escalations]    = [{:notification_interval => 10}]
default[:nagios][:services]["MYSQL-SLAVEIO"][:escalations]  = [{:notification_interval => 10}]
default[:nagios][:services]["MYSQL-SLAVESQL"][:escalations] = [{:notification_interval => 10}]
