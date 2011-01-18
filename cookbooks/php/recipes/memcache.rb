include_recipe "php"

package "dev-php5/pecl-memcache"

php_extension "memcache" do
  template "memcache.ini.erb"
end
