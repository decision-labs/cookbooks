include_recipe "portage"

portage_package_keywords "=dev-libs/dietlibc-0.33_pre20100626"

package "sys-cluster/util-vserver"
package "sys-kernel/vserver-sources"

%w(vprocunhide util-vserver vservers.default).each do |s|
  service s do
    action [:enable, :start]
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

file "/usr/sbin/viotop" do
  action :delete
end

%w(
  mkvs
  viotop
  vrename
).each do |f|
  cookbook_file "/usr/local/sbin/#{f}" do
    source "scripts/#{f}"
    owner "root"
    group "root"
    mode "0755"
  end
end
