include_recipe "java"

package "www-servers/tomcat"

service "tomcat-6" do
  action [ :enable, :start ]
end

{ 
  "localhost.manager.xml" => "/etc/tomcat-6/Catalina/localhost/manager.xml",
  "tomcat-users.xml"      => "/etc/tomcat-6/tomcat-users.xml"
}.each do |src, dest|
  template dest do
    source "#{src}.erb"
    owner "tomcat"
    group "tomcat"
    mode "0644"
    notifies :restart, resources(:service => "tomcat-6")
  end
end
