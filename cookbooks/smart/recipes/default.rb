package "sys-apps/smartmontools"

template "/etc/smartd.conf" do
  source "smartd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[smartd]"
end

service "smartd" do
  action [:enable, :start]
end
