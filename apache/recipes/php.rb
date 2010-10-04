node[:php][:fpm][:socket_user] = "apache"
node[:php][:fpm][:socket_group] = "apache"
node[:php][:fpm][:user] = "apache"
node[:php][:fpm][:group] = "apache"

include_recipe "apache"
include_recipe "php"
