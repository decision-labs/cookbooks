package "net-firewall/shorewall-shell"

service "shorewall" do
  action :enable
end

directory "/etc/shorewall" do
  owner "root"
  group "root"
  mode "0700"
end

cookbook_file "/etc/shorewall/shorewall.conf" do
  source "shorewall.conf"
  owner "root"
  group "root"
  mode "0600"
end

%w(zones interfaces policy params rules).each do |t|
  template "/etc/shorewall/#{t}" do
    source "#{t}.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, resources(:service => "shorewall"), :delayed
  end
end
