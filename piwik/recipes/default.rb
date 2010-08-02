#
# Cookbook Name:: piwik
# Recipe:: default
#
# Copyright 2010, Submarine Internet GmbH
#
class Chef::Recipe
  include ChefUtils::Password
  include ChefUtils::MySQL
end

# source comes in zip archive
package "app-arch/unzip"

piwik_toplevel = "/var/lib/piwik"

directory piwik_toplevel do
  owner "nginx"
  group "nginx"
  mode "750"
end

remote_file "#{piwik_toplevel}/piwik_0.8.zip" do
  source "http://piwik.org/latest.zip"
  owner "nginx"
  group "nginx"
  mode "0644"
  backup 0
  checksum "9b6f032fe818bd362428420143ca110d60420e41cebf6a7b283c88a013ae637d"
  action :create_if_missing
end

execute "piwik-unzip" do
  user "nginx"
  group "nginx"
  cwd piwik_toplevel
  creates "#{piwik_toplevel}/_src_"
  command "unzip #{piwik_toplevel}/piwik_0.8.zip -d _src_"
end

piwik (node['piwik']['fqdn'] || node['fqdn']) do
  action :create
  toplevel piwik_toplevel
end
