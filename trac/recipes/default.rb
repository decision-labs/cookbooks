include_recipe "mysql::server"
include_recipe "gitosis"

portage_package_keywords "=www-apps/trac-0.12"
portage_package_keywords "=www-apps/trac-git-8215"

portage_package_use "www-apps/trac" do
  use %w(mysql)
end

package "www-apps/trac"
package "www-apps/trac-git"
