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

wp_toplevel = "/var/lib/wordpress"

directory wp_toplevel do
  owner "nginx"
  group "nginx"
  mode "750"
end

remote_file "#{wp_toplevel}/wp-3.0.tgz" do
  source "http://wordpress.org/wordpress-3.0.tar.gz"
  owner "nginx"
  group "nginx"
  mode "0644"
  backup 0
  checksum "73414effa3dd10a856b0e8e9a4726e92288fad7e43723106716b72de5f3ed91c"
  action :create_if_missing
end

execute "wp-untar" do
  user "nginx"
  group "nginx"
  cwd wp_toplevel
  creates "#{wp_toplevel}/_src_"
  command "tar xfz #{wp_toplevel}/wp-3.0.tgz && mv wordpress _src_"
end

wordpress_installs = search(:wordpress, "host:#{node['fqdn']}")
wordpress_installs.each do |wp|
  wp['wp'].each do |wpname, wphostname, wpaction|
    wordpress wpname do
      action( (wpaction || :create).to_sym )
      hostname wphostname
    end
  end
end


