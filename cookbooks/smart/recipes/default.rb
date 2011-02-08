package "sys-apps/smartmontools"

service "smartd" do
  supports :status => true
  action :enable
end

template "/etc/smartd.conf" do
  source "smartd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[smartd]", :delayed
end
