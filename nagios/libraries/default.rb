def nagios_service_hosts(nodes, service)
  service_hosts = []
  nodes.each do |n|
    service_hosts << n[:fqdn] if n[:tags].include?("nagios-#{service}")
  end
  service_hosts.join(",")
end
