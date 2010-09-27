#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2010, Submarine Internet GmbH
#
class Chef::Recipe
  include ChefUtils::Password
  include ChefUtils::MySQL
end

require_recipe "memcached::default"

# some plugins are zip files
package "app-arch/unzip"

wp_toplevel = "/var/lib/wordpress"

directory wp_toplevel do
  owner "nginx"
  group "nginx"
  mode "750"
end

include_recipe "wordpress::downloads"

execute "wp-untar" do
  user "nginx"
  group "nginx"
  cwd wp_toplevel
  creates "#{wp_toplevel}/_src_"
  only_if "[[ -f #{wp_toplevel}/wp_de-3.0.1.zip ]]" # should be downloaded via site-cookbooks
  command "unzip #{wp_toplevel}/wp_de-3.0.1.zip && mv wordpress _src_"
end

include_recipe "wordpress::installations"


