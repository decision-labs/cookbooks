include_recipe "portage"
include_recipe "apache"

portage_package_keywords "=net-libs/libopkele-2.0.3"
portage_package_keywords "=www-apache/mod_auth_openid-0.4"

package "www-apache/mod_auth_openid"

cookbook_file "/etc/apache2/modules.d/10_mod_auth_openid.conf" do
  source "10_mod_auth_openid.conf"
  owner "root"
  group "root"
  mode "0644"
end
