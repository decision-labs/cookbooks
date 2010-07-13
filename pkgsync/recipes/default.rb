tag("pkgsync-client")

master = search(:node, "tags:pkgsync-master").first

if master
  file "/etc/rsyncd.secrets" do
    content "pkgsync:#{master[:pkgsync][:password]}\n"
    owner "root"
    group "root"
    mode "0600"
  end

  service "rsyncd" do
    supports :status => true
    action :enable
  end

  template "/etc/rsyncd.conf" do
    source "rsyncd.conf.erb"
    owner "root"
    group "root"
    mode "0640"
    variables :allow => master[:ipaddress]
    notifies :restart, resources(:service => "rsyncd")
  end
end
