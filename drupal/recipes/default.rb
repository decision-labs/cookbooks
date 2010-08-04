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

drupal_toplevel = "/var/lib/drupal"

directory drupal_toplevel do
  owner "nginx"
  group "nginx"
  mode "750"
end

[
 ["4.7.3", "8f74dbd298ffb7c0ad3bc23a96347a3d2854bdc358fdd84d125e1a3791016c3a"]
].each do |dversion, filechecksum|
  destfile = "drupal-#{dversion}.tar.gz"

  remote_file "#{drupal_toplevel}/#{destfile}" do
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
    cwd drupal_toplevel
    creates "#{drupal_toplevel}/_#{dversion}_"
    command(["tar xfz #{drupal_toplevel}/#{destfile}",
             "mv drupal-#{dversion} _#{dversion}_"].join(" && "))
  end
end

search(:drupal, "host:#{node['fqdn']}").each do |drupal_obj|
  drupal_obj["drupal"].each do |drupal_host, drupal_plugins, drupal_version, drupal_action|
    drupal drupal_host do
      toplevel drupal_toplevel
      plugins  drupal_plugins || []
      version  drupal_version || "4.7.3"
      action   (drupal_action || :create).to_sym
    end
  end
end
