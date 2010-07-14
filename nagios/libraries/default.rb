def nagios_service_hosts(hosts, service)
  service_hosts = []
  hosts.each do |n|
    service_hosts << n[:fqdn] if n[:tags].include?("nagios-#{service}")
  end
  service_hosts.join(",")
end
