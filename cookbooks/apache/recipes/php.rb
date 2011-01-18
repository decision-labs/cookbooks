node[:php][:fpm][:pools]["default"][:socket_user] = "apache"
node[:php][:fpm][:pools]["default"][:socket_group] = "apache"
node[:php][:fpm][:pools]["default"][:user] = "apache"
node[:php][:fpm][:pools]["default"][:group] = "apache"

include_recipe "apache::fastcgi"
include_recipe "php"
