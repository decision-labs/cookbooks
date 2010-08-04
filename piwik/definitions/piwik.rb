require 'ostruct'
require 'digest/md5'

define :piwik, :action => :create do
  
  piwik_name      = params[:name]
  piwik_toplevel  = params[:toplevel] || "/var/lib/piwik"
  destdir         = "#{piwik_toplevel}/#{piwik_name}"
  mysql_user_name = "piwik_%s" % Digest::MD5.new.update(piwik_name).hexdigest[0..6].to_s
  mysql_user      = OpenStruct.new(:name => mysql_user_name,
                                   :pass => get_password("mysql/#{mysql_user_name}"),
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
      content "MySQL User for #{piwik_name}\nUser: #{mysql_user.name}\nPass: #{mysql_user.pass}\n"
      owner "nginx"
      group "nginx"
      mode "644"
    end
    
    execute "Create #{destdir}/piwik/plugins/GeoIP" do
      user "nginx"
      group "nginx"
      cwd "#{destdir}/piwik/plugins/"
      creates "#{destdir}/piwik/plugins/GeoIP"
      command "cp -a #{piwik_toplevel}/_src_/piwik/plugins/GeoIP ."
    end
  else
    directory destdir do
      action params[:action]
      recursive true
    end
    file "/etc/nginx/servers/piwik_#{piwik_name}.conf" do
      action params[:action]
    end
    mysql_drop_user(mysql_user) if mysql_user_exists?(mysql_user)
    mysql_drop_database(mysql_user.name) if mysql_database_exists?(mysql_user.name)
  end
end
