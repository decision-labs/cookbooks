package "dev-db/couchdb"

service "couchdb" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "dev-db/couchdb")
end

nagios_service "COUCHDB"
