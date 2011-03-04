include ChefUtils::Account

action :create do
  Chef::Log.info("a")
  #include_recipe "monit"
  Chef::Log.info("b")

  user = getpwnam(new_resource.name)

  Chef::Log.info("c")
  template "/etc/init.d/monit.#{user[:name]}" do
    source "monit.initd"
    cookbook "monit"
    owner "root"
    group "root"
    mode "0755"
    variables :user => user
  end

  service "monit.#{user[:name]}" do
    supports :restart => true, :status => true
    action :enable
  end

  template "#{user[:dir]}/.monitrc.local" do
    source new_resource.template
    owner user[:name]
    group user[:group][:name]
    variables :user => user
    notifies :restart, resources(:service => "monit.#{user[:name]}")
  end

  template "#{user[:dir]}/.monitrc" do
    source "monitrc"
    cookbook "monit"
    owner user[:name]
    group user[:group][:name]
    mode "0600"
    variables :user => user
    notifies :restart, resources(:service => "monit.#{user[:name]}")
  end
end
