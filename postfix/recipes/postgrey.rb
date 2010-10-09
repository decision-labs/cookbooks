package "mail-filter/postgrey"

service "postgrey" do
  action :enable
end

template "/etc/conf.d/postgrey" do
  source "postgrey.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "postgrey")
end
