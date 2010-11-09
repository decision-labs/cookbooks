define :nagios_service, :action => :enable do
  if tagged?("nagios-client")
    enabled = if params[:action] == :enable
                true
              else
                false
              end
    node.default[:nagios][:services][params[:name]][:enabled] = enabled
  end
end
