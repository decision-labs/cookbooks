package "app-admin/sudo"

template "/etc/sudoers" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode "0440"
end
