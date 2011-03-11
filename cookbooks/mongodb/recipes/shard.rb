tag("mongos")

include_recipe "mongodb::default"

link "/etc/init.d/mongos" do
  to "/etc/init.d/mongodb"
end

file "/var/log/mongodb/mongos.log" do
  owner "mongodb"
  group "mongodb"
  mode "0644"
end

opts = ["--configdb #{node[:mongos][:configdb].join(',')}"]

template "/etc/conf.d/mongos" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[mongos]"
  variables :exec => "/usr/bin/mongos",
            :bind_ip => node[:mongos][:bind_ip],
            :port => node[:mongos][:port],
            :opts => opts.join(' ')
end

service "mongos" do
  action [:enable, :start]
end

template "/etc/logrotate.d/mongos" do
  source "mongodb.logrotate"
  owner "root"
  group "root"
  mode "0644"
  variables :svcname => "mongos"
end

if tagged?("nagios-client")
  nrpe_command "check_mongos" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/mongodb/mongos.pid mongos"
  end

  nagios_service "MONGOS" do
    check_command "check_nrpe!check_mongos"
    servicegroups "mongodb"
  end
end
