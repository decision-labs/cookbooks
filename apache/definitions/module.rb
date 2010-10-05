define :apache_module, :action => :create, :template => nil do
  include_recipe "apache"

  template "/etc/apache2/modules.d/#{params[:name]}.conf" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :restart, resources(:service => "apache2")
  end
end
