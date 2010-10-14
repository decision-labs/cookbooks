include_recipe "portage"
include_recipe "apache"

portage_package_use "www-servers/apache|dav" do
  package "www-servers/apache"
  use "apache2_modules_dav apache2_modules_dav_fs apache2_modules_dav_lock"
end

apache_module "45_mod_dav" do
  template "45_mod_dav.conf"
end
