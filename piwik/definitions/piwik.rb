require 'ostruct'

define :piwik, :action => :create do
  
  piwik_name     = params[:name]
  piwik_toplevel = params[:toplevel] || "/var/lib/piwik"
  destdir        = "#{piwik_toplevel}/#{piwik_name}"
  mysql_user     = OpenStruct.new(:name => "piwik_user",
                                  :pass => get_password("mysql/piwik_user"),
                                  :host => 'localhost')
  if params[:action] == :create

    unless mysql_user_exists?(mysql_user)
      mysql_create_user(mysql_user, mysql_user.pass)
    end
    
    mysql_database mysql_user.name do
      owner mysql_user.name
      action :create
    end

    execute "piwik-create-#{piwik_name}" do
      user "nginx"
      group "nginx"
      cwd piwik_toplevel
      creates destdir
      command "cp -a #{piwik_toplevel}/_src_ #{destdir}"
    end
    
    template "/etc/nginx/servers/piwik_#{piwik_name}.conf" do
      source "piwik.nginx.conf.erb"
      owner "root"
      group "root"
      mode "644"
      variables({:piwik_server_name => piwik_name, :piwik_dirname => destdir })
      backup 0
    end

    file "#{destdir}/.user" do
      content "MySQL User\nUser: #{mysql_user.name}\nPass: #{mysql_user.pass}\n"
      owner "nginx"
      group "nginx"
      mode "644"
    end
    
  else
    directory destdir do
      action params[:action]
      recursive true
    end
    file "/etc/nginx/servers/piwik_#{piwik_name}.conf" do
      action :delete
    end
    mysql_drop_user(mysql_user) if mysql_user_exists?(mysql_user)
    mysql_drop_database(mysql_user.name) if mysql_database_exists?(mysql_user.name)
  end
end
