include_recipe "portage"
include_recipe "apache"

portage_package_keywords "~www-apache/passenger-2.2.15"

package "www-apache/passenger"

apache_module "30_mod_passenger" do
  template "30_mod_passenger.conf"
end
