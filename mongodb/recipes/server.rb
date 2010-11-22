tag("mongodb")

include_recipe "mongodb::default"

service "mongodb" do
  supports :status => true, :restart => true
  action :enable
end

template "/etc/conf.d/mongodb" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mongodb")
end
