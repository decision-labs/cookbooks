package "dev-db/couchdb"

service "couchdb" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "dev-db/couchdb")
end

if tagged?("nagios-client")
  node.default[:nagios][:services]["COUCHDB"][:enabled] = true
end
