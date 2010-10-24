define :syslog_config, :source => nil, :variables => {} do
  template = if params[:template]
    params[:template]
  else
    params[:source]
  end

  template "/etc/syslog-ng/conf.d/#{params[:name]}.conf" do
    owner "root"
    group "root"
    mode "0644"
    source template
    variables params[:variables]
    notifies :restart, resources(:service => "syslog-ng")
  end
end
