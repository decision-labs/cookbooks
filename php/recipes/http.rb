include_recipe "php"

package "dev-php5/pecl-http"

php_extension "http" do
  template "http.ini.erb"
end
