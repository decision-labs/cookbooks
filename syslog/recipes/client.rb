include_recipe "syslog"

server_nodes = search(:node, "tags:syslog-server").map { |n| n["fqdn"] }
rsyslog_server = node[:syslog][:server] ? node[:syslog][:server] : server_nodes.first

if rsyslog_server and not server_nodes.include?(node[:fqdn])
  template "/etc/rsyslog.d/remote.conf" do
    source "remote.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
    variables(:server => rsyslog_server)
    notifies :reload, resources(:service => "rsyslog"), :delayed
  end
end
