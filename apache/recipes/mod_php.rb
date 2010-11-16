node[:php][:sapi] = "apache2"

include_recipe "apache"
include_recipe "php"

apache_module "70_mod_php5" do
  template "70_mod_php5.conf"
end
