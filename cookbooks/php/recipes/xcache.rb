include_recipe "php"

package "dev-php5/xcache"

php_extension "xcache" do
  template "xcache.ini.erb"
end
