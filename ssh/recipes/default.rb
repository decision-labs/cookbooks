package "net-misc/openssh"

%w(ssh sshd).each do |f|
  template "/etc/ssh/#{f}_config" do
    source "#{f}_config.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end

service "sshd" do
  action [ :enable, :start ]
  subscribes :restart, resources(:template => "/etc/ssh/sshd_config")
end
