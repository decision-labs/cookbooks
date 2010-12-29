include_recipe "php"

portage_package_keywords "=dev-php5/xcache-1.3.1"

package "dev-php5/xcache"

php_extension "xcache" do
  template "xcache.ini.erb"
end
