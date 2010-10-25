tag("pkgsync-master")

include_recipe "password"

node[:pkgsync][:password] = get_password("pkgsync")

clients = search(:node, "tags:pkgsync-client")

file "/etc/pkgsync.secret" do
  content node[:pkgsync][:password]
  owner "root"
  group "root"
  mode "0600"
end

template "/usr/sbin/pkgsync" do
  source "pkgsync.erb"
  owner "root"
  group "root"
  mode "0755"
  variables :clients => clients
end

cron_hourly "pkgsync" do
  command "/usr/sbin/pkgsync"
end
