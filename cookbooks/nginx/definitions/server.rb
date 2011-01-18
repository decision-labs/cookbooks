define :nginx_server, :action => :create, :template => nil do
  include_recipe "nginx"

  template "/etc/nginx/servers/#{params[:name]}.conf" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :restart, resources(:service => "nginx")
  end
end
