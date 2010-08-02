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

[
 # Piwik distribution
 ["http://piwik.org/latest.zip", "#{piwik_toplevel}/piwik_0.8.zip",
  "9b6f032fe818bd362428420143ca110d60420e41cebf6a7b283c88a013ae637d"],
 # GeoLocation plugin for piwik
 ["http://dev.piwik.org/trac/attachment/ticket/45/GeoIP.zip?format=raw",
  "#{piwik_toplevel}/geoip_plugin.zip",
  "92d880a01418a56735f594771aefd437f9fe248c7d837a126597d3d732d7051b"],
 # MaxMind GeoLocation database
 ["http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz",
  "#{piwik_toplevel}/GeoLiteCity.dat.gz",
  "13f12e298b4edb33e9942824b0845a169ada1ec874d1506d8f4d47db1d7b6584"
 ]
].each do |src_url, dest_file, sha256checksum|
  remote_file dest_file do
    source src_url
    owner "nginx"
    group "nginx"
    mode "0644"
    backup 0
    checksum sha256checksum
    action :create_if_missing
  end
end

execute "piwik-unzip" do
  user "nginx"
  group "nginx"
  cwd piwik_toplevel
  creates "#{piwik_toplevel}/_src_"
  command "unzip #{piwik_toplevel}/piwik_0.8.zip -d _src_"
end

execute "geoplugin-unzip" do
  user "nginx"
  group "nginx"
  cwd "#{piwik_toplevel}/_src_/piwik/plugins"
  creates "#{piwik_toplevel}/_src_/piwik/plugins/GeoIP"
  command "unzip #{piwik_toplevel}/geoip_plugin.zip"
end

execute "geo-data-unzip" do
  user "nginx"
  group "nginx"
  cwd "#{piwik_toplevel}/_src_/piwik/plugins/GeoIP/libs"
  creates "#{piwik_toplevel}/_src_/piwik/plugins/GeoIP/libs/GeoLiteCity.dat"
  command "gzip -d #{piwik_toplevel}/GeoLiteCity.dat.gz -c > GeoLiteCity.dat"
end

piwik (node['piwik']['fqdn'] || node['fqdn']) do
  action :create
  toplevel piwik_toplevel
end
