include_recipe "portage"
include_recipe "apache"

portage_package_keywords "=www-apache/mod_fastcgi_handler-0.3"

package "www-apache/mod_fastcgi_handler"

apache_module "10_mod_fastcgi_handler" do
  template "10_mod_fastcgi_handler.conf"
end
