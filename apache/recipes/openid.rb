include_recipe "portage"
include_recipe "apache"

portage_package_keywords "=net-libs/libopkele-2.0.3"
portage_package_keywords "=www-apache/mod_auth_openid-0.4"

package "www-apache/mod_auth_openid"

apache_module "10_mod_auth_openid" do
  template "10_mod_auth_openid.conf"
end
