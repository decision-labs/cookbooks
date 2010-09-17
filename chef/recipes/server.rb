tag("chef-server")

include_recipe "chef::client"
include_recipe "couchdb"
include_recipe "nginx::passenger"
include_recipe "openssl"
include_recipe "portage"
include_recipe "rabbitmq"

cookbook_file "/etc/portage/package.keywords/chef-server" do
  source "chef-server.keywords"
  owner "root"
  group "root"
  mode "0644"
end

%w(chef-solr chef-server-api chef-server-webui chef-server).each do |p|
  package "app-admin/#{p}" do
    action :upgrade
  end
end

package "dev-ruby/net-ssh-multi"
package "dev-ruby/net-ssh-gateway"

%w(server solr webui).each do |s|
  template "/etc/chef/#{s}.rb" do
    source "#{s}.rb.erb"
    owner "chef"
    group "chef"
    mode "0600"
  end
end

%w(checksums sandboxes).each do |d|
  directory "/var/lib/chef/#{d}" do
    owner "chef"
    group "chef"
    mode "0770"
  end
end

%w(chef-solr chef-solr-indexer).each do |s|
  service s do
    supports :status => true, :restart => true
    action [ :enable, :start ]
    subscribes :restart, resources(:package => "app-admin/chef-solr", :template => "/etc/chef/solr.rb")
  end
end

# XXX: this is so ugly it makes my eyes bleed.
require 'chef-server-api/version'
node[:chef][:server][:path] = "/usr/lib/ruby/gems/1.8/gems/chef-server-api-#{ChefServerApi::VERSION}"
node[:chef][:webui] = {}
node[:chef][:webui][:path] = "/usr/lib/ruby/gems/1.8/gems/chef-server-webui-#{ChefServerApi::VERSION}"

template "#{node[:chef][:server][:path]}/config.ru" do
  source "server.ru.erb"
  owner "chef"
  group "chef"
  mode "0644"
end

template "#{node[:chef][:webui][:path]}/config.ru" do
  source "webui.ru.erb"
  owner "chef"
  group "chef"
  mode "0644"
end

ssl_certificate "/etc/ssl/nginx/#{node[:fqdn]}" do
  cn node[:fqdn]
end

%w(chef-server-api chef-server-webui).each do |s|
  service s do
    supports :status => true, :restart => true
    action [ :disable, :stop ]
  end

  nginx_server s do
    template "#{s}.nginx.erb"
  end
end

http_request "compact chef couchDB" do
  action :post
  url "#{Chef::Config[:couchdb_url]}/chef/_compact"
  only_if do
    begin
      f = open("#{Chef::Config[:couchdb_url]}/chef")
      JSON::parse(f.read)["disk_size"] > 100_000_000
      f.close
    rescue OpenURI::HTTPError
      nil
    end
  end
end

%w(nodes roles registrations clients data_bags data_bag_items users).each do |view|
  http_request "compact chef couchDB view #{view}" do
    action :post
    url "#{Chef::Config[:couchdb_url]}/chef/_compact/#{view}"
    only_if do
      begin
        f = open("#{Chef::Config[:couchdb_url]}/chef/_design/#{view}/_info")
        JSON::parse(f.read)["view_index"]["disk_size"] > 100_000_000
        f.close
      rescue OpenURI::HTTPError
        nil
      end
    end
  end
end

# allow us to setup an asset server for a chef server.
# per default this is not done, but site-cookbooks can
# override this recipe.
include_recipe "chef::assets"
