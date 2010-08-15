include_recipe "syslog"
include_recipe "syslog::tlsbase"

unless tagged?("syslog-server")
  server_nodes = search(:node, "tags:syslog-server")

  template "/etc/syslog-ng/conf.d/00-remote.conf" do
    source "remote.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
    variables(:server_nodes => server_nodes)
    notifies :restart, resources(:service => "syslog-ng")
  end
end
