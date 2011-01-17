define :nrpe_command do
  node.default[:nagios][:nrpe][:commands][params[:name].to_sym] = params[:command]
end
