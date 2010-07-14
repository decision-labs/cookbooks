tag("nagios-SWRAID")

package "sys-fs/mdadm"

service "mdadm" do
  supports :status => true
  action :enable
end

template "/etc/mdadm.conf" do
  source "mdadm.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mdadm")
end
