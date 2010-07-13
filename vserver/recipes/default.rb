include_recipe "portage"

portage_package_keywords "=sys-cluster/util-vserver-0.30.216_pre*"
portage_package_keywords "=sys-kernel/vserver-sources-2.3.0.36.30.4-r1"

package "sys-cluster/util-vserver"
package "sys-kernel/vserver-sources"

%w(vprocunhide util-vserver vservers.default).each do |s|
  service s do
    supports :status => true
    action [ :enable, :start ]
  end
end

cookbook_file "/etc/vservers/.defaults/fstab" do
  source "fstab"
  owner "root"
  group "root"
  mode "0644"
end

content = nil

begin
  f = resources(:file => "/etc/resolv.conf")
  content = f.content
rescue ArgumentError
  content = "nameserver 8.8.8.8\nnameserver 8.8.4.4\n"
end

file "/etc/vservers/.defaults/files/resolv.conf" do
  content content
  owner "root"
  group "root"
  mode "0644"
end
