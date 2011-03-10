include_recipe "portage"

portage_package_keywords "=dev-lang/spidermonkey-1.7.0-r1"
portage_package_keywords "=dev-db/mongodb-1.8.0_rc1"

package "dev-db/mongodb"

cookbook_file "/etc/init.d/mongodb" do
  source "mongodb.initd"
  owner "root"
  group "root"
  mode "0755"
end

if tagged?("nagios-client")
  portage_package_keywords "=dev-python/pymongo-1.9"
  package "dev-python/pymongo"

  nagios_plugin "mongodb" do
    source "check_mongodb"
  end
end
