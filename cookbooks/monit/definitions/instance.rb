define :monit_instance do
  include_recipe "monit"

  user = params[:name]
  group = params[:group]
  homedir = params[:homedir]

  template "/etc/init.d/monit.#{user}" do
    source "monit.initd"
    cookbook "monit"
    owner "root"
    group "root"
    mode "0755"
    variables :homedir => homedir, :user => user
  end

  service "monit.#{user}" do
    supports :restart => true, :status => true
    action :enable
  end

  template "#{homedir}/.monitrc.local" do
    source params[:template]
    owner user
    group group
    variables :homedir => homedir, :user => user
    notifies :restart, resources(:service => "monit.#{user}")
  end

  template "#{homedir}/.monitrc" do
    source "monitrc"
    cookbook "monit"
    owner user
    group group
    mode "0600"
    variables :homedir => homedir, :user => user
    notifies :restart, resources(:service => "monit.#{user}")
  end
end
