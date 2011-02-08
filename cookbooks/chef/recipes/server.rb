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

%w(chef-solr chef-server-api chef-server).each do |p|
  package "app-admin/#{p}"
end

package "dev-ruby/net-ssh-multi"
package "dev-ruby/net-ssh-gateway"

%w(server solr).each do |s|
  template "/etc/chef/#{s}.rb" do
    source "#{s}.rb.erb"
    owner "chef"
    group "chef"
    mode "0600"
    notifies :restart, "service[chef-solr]"
    notifies :restart, "service[chef-solr-indexer]"
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
    action [:enable, :start]
  end
end

ssl_ca "/etc/ssl/nginx/#{node[:fqdn]}-ca"

ssl_certificate "/etc/ssl/nginx/#{node[:fqdn]}" do
  cn node[:fqdn]
end

cookbook_file "/var/lib/chef/rack/api/config.ru" do
  source "config.ru"
  owner "chef"
  group "chef"
  mode "0644"
  notifies :restart, "service[nginx]"
end

nginx_server "chef-server-api" do
  template "chef-server-api.nginx.erb"
end

service "chef-server-api" do
  action [:disable, :stop]
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

if tagged?("nagios-client")
  nrpe_command "check_chef_server_ssl" do
    command "/usr/lib/nagios/plugins/check_ssl_cert -H localhost -n #{node[:fqdn]} -p 4443 -r /etc/ssl/nginx/#{node[:fqdn]}-ca.crt -w 21 -c 7"
  end

  nrpe_command "check_chef_solr" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr.pid"
  end

  nrpe_command "check_chef_solr_indexer" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr-indexer.pid"
  end

  nagios_service "CHEF-SERVER" do
    check_command "check_chef_server"
    servicegroups "chef"
  end

  nagios_service "CHEF-SERVER-SSL" do
    check_command "check_nrpe!check_chef_server_ssl"
    servicegroups "chef"
  end

  nagios_service "CHEF-SOLR" do
    check_command "check_nrpe!check_chef_solr"
    servicegroups "chef"
  end

  nagios_service "CHEF-SOLR-INDEXER" do
    check_command "check_nrpe!check_chef_solr_indexer"
    servicegroups "chef"
  end
end

# allow us to setup an asset server for a chef server.
# per default this is not done, but site-cookbooks can
# override this recipe.
include_recipe "chef::assets"
