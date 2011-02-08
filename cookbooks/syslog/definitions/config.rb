define :syslog_config, :source => nil, :variables => {} do
  include_recipe "syslog"

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
    cookbook params[:cookbook] if params[:cookbook]
    variables params[:variables]
    notifies :restart, "service[syslog-ng]"
  end
end
