include_recipe "postfix"

file "/etc/postfix/adminaddr" do
  content "#{node[:contacts][:hostmaster]}\n"
  owner "root"
  group "root"
  mode "0644"
end

postconf "forward all local mail to hostmaster" do
  set :forward_path => "/etc/postfix/adminaddr"
end
