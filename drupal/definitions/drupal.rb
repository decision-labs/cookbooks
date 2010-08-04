require 'digest/md5'
require 'ostruct'

define :drupal, :action => :create do

  name            = params[:name]
  toplevel        = params[:toplevel] || "/var/lib/drupal"
  version         = params[:version] || "4.7.3"
  destdir         = "#{toplevel}/#{name}_#{version}"
  nginx_conf      = "/etc/nginx/servers/drupal_#{name}_#{version}.conf"
  mysql_user_name = "drupal_%s" % Digest::MD5.new.update("%s%s"%[name,version]).hexdigest[0..6].to_s
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
    
    execute "drupal-create-#{name}-#{version}" do
      user "nginx"
      group "nginx"
      cwd toplevel
      creates destdir
      command "cp -a #{toplevel}/_#{version}_ #{destdir}"
    end

    template nginx_conf do
      source "drupal.nginx.conf.erb"
      owner "root"
      group "root"
      mode "644"
      variables({:drupal_server_name => name, :drupal_dirname => destdir })
      backup 0
    end
    
    file "#{destdir}/.user" do
      content "MySQL User for #{name}\nUser: #{mysql_user.name}\nPass: #{mysql_user.pass}\n"
      owner "nginx"
      group "nginx"
      mode "644"
    end
    
    mysql_ident = [:name,:pass,:name].map{ |a| mysql_user.send(a) }

    template "#{destdir}/sites/default/settings.php" do
      source "settings.#{version}.php.erb"
      owner "nginx"
      group "nginx"
      mode "644"
      variables({:drupal_db_connect => "mysql://%s:%s@localhost/%s" % mysql_ident})
      backup 0
    end

    instcmdline = ("mysql -u %s -p%s %s < " + (case version
                                               when /4[.]7/ then "database/database.4.1.mysql"
                                               else "this does not exist for #{version}"
                                               end)) % mysql_ident
    execute "install initial drupal db #{name} #{version}" do
      user "nginx"
      group "nginx"
      cwd destdir
      creates "#{destdir}/.mysql_installed"
      command([instcmdline, "touch .mysql_installed"].join(" && "))
    end
    
  else
    directory destdir do
      action params[:action]
      recursive true
    end
    file(nginx_conf) { action params[:action] }
    mysql_drop_user(mysql_user) if mysql_user_exists?(mysql_user)
    mysql_drop_database(mysql_user.name) if mysql_database_exists?(mysql_user.name)
  end
end
