include_attribute "nagios"

# nagios nrpe commands
default[:nagios][:nrpe][:commands][:check_chef_solr] = "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr.pid"
default[:nagios][:nrpe][:commands][:check_chef_solr_indexer] = "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr-indexer.pid"

# nagios service checks
default[:nagios][:services]["CHEF-SOLR"] = {
  :check_command => "check_nrpe!check_chef_solr",
}

default[:nagios][:services]["CHEF-SOLR-INDEXER"] = {
  :check_command => "check_nrpe!check_chef_solr_indexer",
}
