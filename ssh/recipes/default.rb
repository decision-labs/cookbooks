package "net-misc/openssh"

template "/etc/ssh/sshd_config" do
end

template "/etc/ssh/ssh_config" do
end

service "sshd" do
  action [ :enable, :start ]
end
