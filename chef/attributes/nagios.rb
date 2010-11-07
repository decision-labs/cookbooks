include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_chef_server_ssl] = "/usr/lib/nagios/plugins/check_ssl_cert -H localhost -n #{node[:fqdn]} -p 4443 -r /etc/ssl/nginx/#{node[:fqdn]}-ca.crt -w 21 -c 7"
default[:nagios][:nrpe][:commands][:check_chef_solr] = "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr.pid"
default[:nagios][:nrpe][:commands][:check_chef_solr_indexer] = "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr-indexer.pid"
default[:nagios][:nrpe][:commands][:check_chef_webui_ssl] = "/usr/lib/nagios/plugins/check_ssl_cert -H localhost -n #{node[:fqdn]} -p 4444 -r /etc/ssl/nginx/#{node[:fqdn]}-ca.crt -w 21 -c 7"

# nagios service checks
default[:nagios][:services]["CHEF-SERVER"] = {
  :check_command => "check_chef_server",
}

default[:nagios][:services]["CHEF-SERVER-SSL"] = {
  :check_command => "check_nrpe!check_chef_server_ssl",
}

default[:nagios][:services]["CHEF-SOLR"] = {
  :check_command => "check_nrpe!check_chef_solr",
}

default[:nagios][:services]["CHEF-SOLR-INDEXER"] = {
  :check_command => "check_nrpe!check_chef_solr_indexer",
}

default[:nagios][:services]["CHEF-WEBUI"] = {
  :check_command => "check_chef_webui",
}

default[:nagios][:services]["CHEF-WEBUI-SSL"] = {
  :check_command => "check_nrpe!check_chef_webui_ssl",
}
