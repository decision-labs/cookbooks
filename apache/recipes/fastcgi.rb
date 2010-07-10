include_recipe "portage"
include_recipe "apache"

portage_package_keywords "=www-apache/mod_fastcgi_handler-0.3"

# force eix-update, since it does not pick up initial overlays automatically
execute "eix-update" do
  not_if do File.exists?("/var/db/pkg/www-apache/mod_fastcgi_handler-0.3") end
end

package "www-apache/mod_fastcgi_handler"

cookbook_file "/etc/apache2/modules.d/10_mod_fastcgi_handler.conf" do
  source "10_mod_fastcgi_handler.conf"
  owner "root"
  group "root"
  mode "0644"
end
