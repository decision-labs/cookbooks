package "app-portage/layman"

cookbook_file "/etc/layman/layman.cfg" do
  source "layman.cfg"
  owner "root"
  group "root"
  mode "0644"
  backup 0
end

directory "/var/lib/layman" do
  owner "root"
  group "root"
  mode "0755"
end

bash "layman-init" do
  code "layman -f -a hollow; layman -f -a betagarden"
  not_if "test -d /var/lib/layman/betagarden"
end

make_conf "layman" do
  sources %w(/var/lib/layman/make.conf)
end
