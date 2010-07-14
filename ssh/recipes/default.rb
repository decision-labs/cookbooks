tag("nagios-SSH")

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

execute "root-ssh-key" do
  command "ssh-keygen -f /root/.ssh/id_rsa -N ''"
  not_if "test -f /root/.ssh/id_rsa"
end

package "app-admin/denyhosts"

service "denyhosts" do
  supports :status => true
  action :enable
end

cookbook_file "/etc/denyhosts.conf" do
  source "denyhosts.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, resources(:service => "denyhosts"), :delayed
end
