package "net-misc/memcached"
package "dev-php5/pecl-memcache"

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
