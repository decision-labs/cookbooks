include_recipe "portage"

portage_package_keywords "=dev-ruby/god-0.11.0"

# force eix-update, since it does not pick up initial overlays automatically
execute "eix-update" do
  not_if do File.exists?("/var/db/pkg/dev-ruby/god-0.11.0") end
end

package "dev-ruby/god"

%w(/var/run/god /etc/god /etc/god/conf).each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0755"
  end
end

service "god" do
  supports :status => true
  action [ :enable, :start ]
end
