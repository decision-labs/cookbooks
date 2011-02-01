include_recipe "portage"

portage_package_keywords "=dev-lang/spidermonkey-1.7.0-r1"
portage_package_keywords "=dev-db/mongodb-1.6.3"

package "dev-db/mongodb"

if tagged?("nagios-client")
  portage_package_keywords "=dev-python/pymongo-1.9"
  package "dev-python/pymongo"

  nagios_plugin "mongodb" do
    source "check_mongodb"
  end
end
