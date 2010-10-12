include_recipe "portage"
include_recipe "apache"
include_recipe "apache::dav"

portage_package_use "dev-vcs/subversion" do
  use "apache2"
end

package "dev-vcs/subversion"
