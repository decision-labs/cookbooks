node[:php][:sapi] = "apache2"

include_recipe "apache"
include_recipe "php"
