tag("mongoc")

include_recipe "mongodb::default"

directory "/var/lib/mongoc" do
  owner "mongodb"
  group "root"
  mode "0755"
end

link "/etc/init.d/mongoc" do
  to "/etc/init.d/mongodb"
end

service "mongoc" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/conf.d/mongoc" do
  source "mongoc.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mongoc")
end
