package "net-misc/memcached"

service "memcached" do
  supports :status => true
  action :enable
end

template "/etc/conf.d/memcached" do
  source "memcached.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "memcached")
end

if tagged?("nagios-client")
  portage_package_keywords "=dev-perl/Nagios-Plugins-Memcached-0.02"
  package "dev-perl/Nagios-Plugins-Memcached"

  nagios_service "MEMCACHED"
end

# munin plugins
if tagged?("munin-node")
  munin_plugin "memcached_bytes" do
    source "munin_memcached.pl"
  end
  munin_plugin "memcached_counters" do
    source "munin_memcached.pl"
  end
  munin_plugin "memcached_rates" do
    source "munin_memcached.pl"
  end
end
