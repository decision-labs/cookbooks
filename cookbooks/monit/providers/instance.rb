include ChefUtils::Account

action :create do
  portage_package_keywords "=app-admin/monit-5.2.2"

  package "app-admin/monit"

  file "/etc/init.d/monit" do
    action :delete
  end

  directory "/etc/monit.d" do
    action :delete
    recursive true
  end

  template "/etc/monitrc" do
    action :delete
  end

  nagios_plugin "monit" do
    source "check_monit"
    cookbook "monit"
  end

  user = getpwnam(new_resource.name)

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
