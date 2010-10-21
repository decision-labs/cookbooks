define :monit_config, :template => nil do
  include_recipe "monit"

  template "/etc/monit.d/#{params[:name]}" do
    source params[:template]
    owner "root"
    group "root"
    mode "0600"
    variables :params => params
    notifies :run, resources(:execute => "monit reload"), :immediately
  end
end
