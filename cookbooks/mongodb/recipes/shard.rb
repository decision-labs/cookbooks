tag("mongos")

include_recipe "mongodb::default"

file "/var/log/mongodb/mongos.log" do
  owner "mongodb"
  group "mongodb"
  mode "0644"
end

cookbook_file "/etc/init.d/mongos" do
  source "mongos.initd"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/conf.d/mongos" do
  source "mongos.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[mongos]"
  variables :bind_ip => node[:mongos][:bind_ip],
            :port => node[:mongos][:port],
            :configdb => node[:mongos][:configdb]
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
