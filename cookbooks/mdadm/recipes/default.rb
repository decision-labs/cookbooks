untag("nagios-SWRAID")

package "sys-fs/mdadm"

service "mdadm" do
  action [:disable, :stop]
end

template "/etc/mdadm.conf" do
  source "mdadm.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
