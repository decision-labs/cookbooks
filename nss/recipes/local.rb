cookbook_file "/etc/pam.d/system-auth" do
  source "local/system-auth.pamd"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/nsswitch.conf" do
  source "local/nsswitch.conf"
  owner "root"
  group "root"
  mode "0644"
end
