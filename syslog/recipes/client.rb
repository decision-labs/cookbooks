include_recipe "rsyslog"

rsyslog_server = node[:rsyslog][:server] ? node[:rsyslog][:server] : search(:node, "rsyslog_server:true").map { |n| n["fqdn"] }.first

unless node[:rsyslog][:server]
  template "/etc/rsyslog.d/remote.conf" do
    source "remote.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
    variables(:server => rsyslog_server)
    notifies :reload, resources(:service => "rsyslog"), :delayed
  end

  file "/etc/rsyslog.d/server.conf" do
    action :delete
    notifies :reload, resources(:service => "rsyslog"), :delayed
  end
end
