package "dev-db/couchdb"

service "couchdb" do
  action [:enable, :start]
end

nrpe_command "check_couchdb" do
  command "/usr/lib/nagios/plugins/check_http -H localhost -p 5984 -s couchdb"
end

nagios_service "COUCHDB" do
  check_command "check_nrpe!check_couchdb"
end
