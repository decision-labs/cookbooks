package "dev-db/couchdb"

service "couchdb" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "dev-db/couchdb")
end

nrpe_command "check_couchdb" do
  command "/usr/lib/nagios/plugins/check_http -H localhost -p 5984 -s couchdb"
end

nagios_service "COUCHDB" do
  check_command "check_nrpe!check_couchdb"
end
