#
# Cookbook Name:: drupal
# Recipe:: default
#
# Copyright 2010, Submarine Internet GmbH
#

class Chef::Recipe
  include ChefUtils::Password
  include ChefUtils::MySQL
end

node[:drupal][:toplevel] = "/var/lib/drupal"

directory node[:drupal][:toplevel] do
  owner "nginx"
  group "nginx"
  mode "750"
end

[
 ["4.7.3", "8f74dbd298ffb7c0ad3bc23a96347a3d2854bdc358fdd84d125e1a3791016c3a"],
 ["4.7.10", "34a78b7ace57518464dfae4d85ddcd50182ec5276e5282555cdfaf20f2c2bf1b"]
].each do |dversion, filechecksum|
  destfile = "drupal-#{dversion}.tar.gz"

  remote_file "#{node[:drupal][:toplevel]}/#{destfile}" do
    source "http://ftp.drupal.org/files/projects/drupal-#{dversion}.tar.gz"
    owner "nginx"
    group "nginx"
    mode "0644"
    backup 0
    checksum filechecksum
    action :create_if_missing
  end

  execute "drupal-untar" do
    user "nginx"
    group "nginx"
    cwd node[:drupal][:toplevel]
    creates "#{node[:drupal][:toplevel]}/_#{dversion}_"
    command(["tar xfz #{node[:drupal][:toplevel]}/#{destfile}",
             "mv drupal-#{dversion} _#{dversion}_"].join(" && "))
  end
end

include_recipe "drupal::installations"
