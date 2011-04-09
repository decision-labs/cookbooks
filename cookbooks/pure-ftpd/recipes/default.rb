portage_package_use "net-ftp/pure-ftpd" do
  use %w(vchroot)
end

package "net-ftp/pure-ftpd"

template "/etc/conf.d/pure-ftpd" do
  source "pure-ftpd.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[pure-ftpd]"
end

file "/etc/pureftpd.passwd" do
  owner "root"
  group "root"
  mode "0600"
end

execute "pure-pw-mkdb" do
  command "pure-pw mkdb /etc/pureftpd.pdb -f /etc/pureftpd.passwd"
  only_if do
    test ?>, "/etc/pureftpd.passwd", "/etc/pureftpd.pdb"
  end
end

service "pure-ftpd" do
  action [:enable, :start]
end
