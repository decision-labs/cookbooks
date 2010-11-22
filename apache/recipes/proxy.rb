include_recipe "portage"
include_recipe "apache"

portage_package_use "www-servers/apache|proxy" do
  package "www-servers/apache"
  use "apache2_modules_proxy_http"
end
