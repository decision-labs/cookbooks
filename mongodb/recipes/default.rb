#
# Cookbook Name:: mongo
# Recipe:: default
#
# Copyright 2010, Submarine Internet GmbH
#

include_recipe "portage"

portage_package_keywords "=dev-lang/spidermonkey-1.7.0-r1"
portage_package_keywords "=dev-db/mongodb-1.4.3"

package "dev-db/mongodb"

service "mongodb" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "dev-db/mongodb")
end
