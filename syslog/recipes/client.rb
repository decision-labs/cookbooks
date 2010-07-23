include_recipe "syslog"

unless tagged?("syslog-server")
  server_nodes = search(:node, "tags:syslog-server")

  file "/etc/rsyslog.d/remote.conf" do
    action :delete
  end

  template "/etc/rsyslog.d/00-remote.conf" do
    source "remote.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
    variables(:server_nodes => server_nodes)
    notifies :reload, resources(:service => "rsyslog")
  end
end
