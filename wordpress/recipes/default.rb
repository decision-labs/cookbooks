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

# some plugins are zip files
package "app-arch/unzip"

wp_toplevel = "/var/lib/wordpress"

directory wp_toplevel do
  owner "nginx"
  group "nginx"
  mode "750"
end

[
 # source
 ["wp-3.0.tgz",
  "http://wordpress.org/wordpress-3.0.tar.gz",
  "73414effa3dd10a856b0e8e9a4726e92288fad7e43723106716b72de5f3ed91c"
 ],

 # plugins
 [
  "nginx-compatibility.0.2.3.zip",
  "http://downloads.wordpress.org/plugin/nginx-compatibility.0.2.3.zip",
  "c8d848b49acfc964e8de734147b1e621aa6267c1af4b5e8ad7059bcc023d88e7"
 ],

 # language bundles
 [
  "de_DE.mo_DU.zip",
  "http://counter.wordpress-deutschland.org/dlcount.php?id=static&url=/sprachdatei/de_DE.mo.zip",
  "a48026b04caf12cf43fc32fd2b0ecee6cba33b6d86f5d471a18b7881397c6bd0"
 ],
 [
  "de_DE.mo_SIE.zip",
  "http://counter.wordpress-deutschland.org/dlcount.php?id=static&url=/sprachdatei/de_DE_Sie.mo.zip",
  "69db84b3c00bbcf511c8ff4bf0e89784068d4292c35c522763f55eaff78c859d"
 ],
].each do |destfile, filesrc, filechecksum|
  remote_file "#{wp_toplevel}/#{destfile}" do
    source filesrc
    owner "nginx"
    group "nginx"
    mode "0644"
    backup 0
    checksum filechecksum
    action :create_if_missing
  end
end

execute "wp-untar" do
  user "nginx"
  group "nginx"
  cwd wp_toplevel
  creates "#{wp_toplevel}/_src_"
  command "tar xfz #{wp_toplevel}/wp-3.0.tgz && mv wordpress _src_"
end

search(:wordpress, "host:#{node['fqdn']}").each do |wp|
  wp['wp'].each do |wpname, wphostname, wpopts|
    wordpress wpname do
      hostname wphostname
      action( (wpopts["action"] || :create).to_sym )
      plugins( wpopts["plugins"] || [] )
      language( wpopts["lang"] || nil )
    end
  end
end


