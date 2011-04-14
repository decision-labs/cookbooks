tag("mongoc")

include_recipe "mongodb::default"

directory node[:mongoc][:dbpath] do
  owner "mongodb"
  group "root"
  mode "0755"
end

file "/var/log/mongodb/mongoc.log" do
  owner "mongodb"
  group "mongodb"
  mode "0644"
end

cookbook_file "/etc/init.d/mongoc" do
  source "mongodb.initd"
  owner "root"
  group "root"
  mode "0755"
end

opts = %w(--journal --rest --configsvr)

template "/etc/conf.d/mongoc" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[mongoc]"
  variables :bind_ip => node[:mongoc][:bind_ip],
            :port => node[:mongoc][:port],
            :dbpath => node[:mongoc][:dbpath],
            :opts => opts
end

service "mongoc" do
  action [:enable, :start]
end

template "/etc/logrotate.d/mongoc" do
  source "mongodb.logrotate"
  owner "root"
  group "root"
  mode "0644"
  variables :svcname => "mongoc"
end

if tagged?("nagios-client")
  nrpe_command "check_mongoc" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/mongodb/mongoc.pid mongod"
  end

  nagios_service "MONGOC" do
    check_command "check_nrpe!check_mongoc"
    servicegroups "mongodb"
  end
end
