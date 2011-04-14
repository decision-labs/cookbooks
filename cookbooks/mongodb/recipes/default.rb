portage_package_keywords "=dev-db/mongodb-1.8.1"

portage_package_use "dev-db/mongodb" do
  use %w(v8)
end

package "dev-db/mongodb"

if tagged?("nagios-client")
  portage_package_keywords "=dev-python/pymongo-1.9"
  package "dev-python/pymongo"

  nagios_plugin "mongodb" do
    source "check_mongodb"
  end
end
