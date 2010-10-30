package "app-admin/monit"

service "monit" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

directory "/etc/monit.d" do
  owner "root"
  group "root"
  mode "0700"
end

file "/etc/monit.d/dummy" do
  content ""
  owner "root"
  group "root"
  mode "0600"
end

template "/etc/monitrc" do
  source "monitrc"
  owner "root"
  group "root"
  mode "0600"
  notifies :restart, resources(:service => "monit")
end

execute "monit reload" do
  command "/usr/bin/monit reload"
  action :nothing
end
