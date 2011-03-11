tag("mongodb")

include_recipe "mongodb::default"

directory node[:mongodb][:dbpath] do
  owner "mongodb"
  group "root"
  mode "0755"
end

file "/var/log/mongodb/mongodb.log" do
  owner "mongodb"
  group "mongodb"
  mode "0644"
end

opts = %w(--rest)
opts << "--dbpath #{node[:mongodb][:dbpath]}"
opts << "--shardsvr" if node[:mongodb][:shardsvr]
opts << "--replSet #{node[:mongodb][:replication][:set]}" if node[:mongodb][:replication][:set]

template "/etc/conf.d/mongodb" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[mongodb]"
  variables :exec => "/usr/bin/mongod",
            :bind_ip => node[:mongodb][:bind_ip],
            :port => node[:mongodb][:port],
            :opts => opts.join(' ')
end

service "mongodb" do
  action [:enable, :start]
end

template "/etc/logrotate.d/mongodb" do
  source "mongodb.logrotate"
  owner "root"
  group "root"
  mode "0644"
  variables :svcname => "mongodb"
end

if tagged?("nagios-client")
  nrpe_command "check_mongodb" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/mongodb/mongodb.pid mongod"
  end

  nagios_service "MONGODB" do
    check_command "check_nrpe!check_mongodb"
    servicegroups "mongodb"
  end

  { # name             command         warn crit check note
    :connect     => %w(connect         2    5    1     15),
    :connections => %w(connections     80   90   1     15),
    #:flush       => %w(flushing        2    5    60    180),
    :lock        => %w(lock            2    5    60    180),
    #:memory      => %w(memory          2    5    5     180),
    :repl_lag    => %w(replication_lag 2    5    60    180),
    :repl_state  => %w(replset_state   0    0    1     15),
  }.each do |name, p|
      name = name.to_s
      command_name = "check_mongo_#{name}"
      service_name = "MONGODB-#{name.upcase.gsub(/_/, '-')}"

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mongodb -H localhost -P 27017 -A #{p[0]} -W #{p[1]} -C #{p[2]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!#{command_name}"
      check_interval p[3]
      notification_interval p[4]
      servicegroups "mongodb"
    end

    nagios_service_dependency service_name do
      depends %w(MONGODB)
    end
  end

  unless node[:mongodb][:replication][:set]
    node.default[:nagios][:services]["MONGODB-REPL-STATE"][:enabled] = false
    node.default[:nagios][:services]["MONGODB-REPL-LAG"][:enabled] = false
  end
end
