portage_package_keywords "=app-admin/monit-5.2.2"

package "app-admin/monit"

file "/etc/init.d/monit" do
  action :delete
end

directory "/etc/monit.d" do
  action :delete
  recursive true
end

template "/etc/monitrc" do
  action :delete
end

nagios_plugin "monit" do
  source "check_monit"
end
