define :nagios_host do
  if tagged?("nagios-client")
    fqdn = params.delete(:name)

    params[:host_name] = fqdn

    node.default[:nagios][:hosts][fqdn] = params
  end
end
