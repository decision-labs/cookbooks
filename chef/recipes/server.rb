include_recipe "chef::client"
include_recipe "couchdb"
include_recipe "rabbitmq"

cookbook_file "/etc/portage/package.keywords/chef-server" do
  source "chef-server.keywords"
  owner "root"
  group "root"
  mode "0644"
end

%w(chef-solr chef-server-api chef-server).each do |p|
  package "app-admin/#{p}" do
    action :upgrade
  end
end

%w(server solr).each { |s|
  template "/etc/chef/#{s}.rb" do
    source "#{s}.rb.erb"
    owner "chef"
    group "chef"
    mode "0600"
  end
}

%w(checksums sandboxes).each { |d|
  directory "/var/lib/chef/#{d}" do
    owner "chef"
    group "chef"
    mode "0770"
  end
}

%w(chef-solr chef-solr-indexer).each { |s|
  service s do
    supports :status => true, :restart => true
    action [ :enable, :start ]
    subscribes :restart, resources(:package => "app-admin/chef-solr", :template => "/etc/chef/solr.rb")
  end
}

service "chef-server-api" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "app-admin/chef-server-api", :template => "/etc/chef/server.rb")
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
