default[:chef][:client][:server_url] = "http://chef.#{node[:domain]}:4000"

begin
  f = open("/etc/chef/amqp_pass")
  set[:chef][:server][:amqp_pass] = f.read.strip
  f.close
rescue
  set[:chef][:server][:amqp_pass] = ""
end
