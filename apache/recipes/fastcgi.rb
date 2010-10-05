include_recipe "portage"
include_recipe "apache"

portage_package_keywords "=www-apache/mod_fastcgi_handler-0.3"

# force eix-update, since it does not pick up initial overlays automatically
execute "eix-update" do
  not_if do File.exists?("/var/db/pkg/www-apache/mod_fastcgi_handler-0.3") end
end

package "www-apache/mod_fastcgi_handler"

apache_module "10_mod_fastcgi_handler" do
  template "10_mod_fastcgi_handler.conf"
end
