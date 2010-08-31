package "net-misc/memcached"

service "memcached" do
  supports :status => true
  action [:enable, :start]
end
