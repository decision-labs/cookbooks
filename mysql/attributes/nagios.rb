{
  :uptime => %w(uptime 10: 0:),
  :ctime  => %w(connection-time 0.1 0.3 1),
  :tchit  => %w(threadcache-hitrate 90: 80: 60 1440),
  :qchit  => %w(qcache-hitrate 90: 80: 60 60 never),
  :qclow  => %w(qcache-lowmem-prunes 1 10 60 60 never),
  :slow   => %w(slow-queries 0.1 1 60),
  :long   => %w(long-running-procs 10 20),
  :tabhit => %w(tablecache-hitrate 99: 95: 60 1440),
  :lock   => %w(table-lock-contention 1 2 60),
  :index  => %w(index-usage 90: 80: 60 60 never),
  :tmptab => %w(tmp-disk-tables 25 50 60 1440),
  :kchit  => %w(keycache-hitrate 99: 95: 60 1440),
  :bphit  => %w(bufferpool-hitrate 99: 95: 60 1440),
  :bpwait => %w(bufferpool-wait-free 1 10 60 1440),
  :logwait => %w(log-waits 1 10 60 1440),
}.each do |name, p|
  name = name.to_s
  command_name = "check_mysql_#{name}"

  p[3] ||= "5"
  p[4] ||= "60"
  p[5] ||= "24x7"

  default[:nagios][:nrpe][:commands][command_name] = "/usr/lib/nagios/plugins/check_mysql_health_wrapper --mode #{p[0]} --warning #{p[1]} --critical #{p[2]}"
  default[:nagios][:services]["MYSQL-#{name.upcase}"] = {
    :check_command => "check_nrpe!check_mysql_#{name}",
    :normal_check_interval => p[3],
    :notification_interval => p[4],
    :notification_period => p[5]
  }
end
