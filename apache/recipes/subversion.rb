include_recipe "portage"
include_recipe "apache"

portage_package_use "www-servers/apache|dav" do
  package "www-servers/apache"
  use "apache2_modules_dav apache2_modules_dav_fs apache2_modules_dav_lock"
end

portage_package_use "dev-vcs/subversion" do
  use "apache2"
end

package "dev-vcs/subversion"
