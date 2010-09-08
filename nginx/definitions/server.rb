define :nginx_server, :source => nil, :variables => {} do
  template "/etc/nginx/servers/#{params[:name]}.conf" do
    source params[:source]
    owner "root"
    group "root"
    mode "0644"
    variables params[:variables]
    notifies :restart, resources(:service => "nginx")
  end
end
