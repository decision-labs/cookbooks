default[:chef][:client][:server_url] = "https://chef.#{node[:domain]}:4443"

begin
  f = open("/etc/chef/amqp_pass")
  set[:chef][:server][:amqp_pass] = f.read.strip
  f.close
rescue
  set[:chef][:server][:amqp_pass] = ""
end
