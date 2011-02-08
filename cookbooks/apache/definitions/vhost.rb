define :apache_vhost, :action => :create, :template => nil do
  include_recipe "apache"

  template "/etc/apache2/vhosts.d/#{params[:name]}.conf" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :restart, "service[apache2]"
  end
end
