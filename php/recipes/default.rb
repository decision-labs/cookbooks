include_recipe "portage"
include_recipe "mysql::default"

sapi = node[:php][:sapi]
sapi_use = []

case sapi
when "apache2"
  include_recipe "apache"
  sapi_use = %w(apache2)
  user = "apache"
  group = "apache"
  service_name = "apache2"

when "fpm"
  sapi_use = %w(cgi fpm)
  user = node[:php][:fpm][:user]
  group = node[:php][:fpm][:group]
  service_name = "php-fpm"
end

portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + sapi_use
end

package "dev-lang/php"

# this is ugly
php_version = %x(eix --installed --pure-packages --format '<bestversion:VERSION>' -e dev-lang/php).split('.')
php_version = "#{php_version[0]}.#{php_version[1]}"
node.set[:php][:version] = php_version

[
  node[:php][:tmp_dir],
  node[:php][:upload][:tmp_dir],
  node[:php][:session][:save_path]
].each do |p|
  directory p do
    owner user
    group group
    mode "0750"
  end
end

file "/var/log/php-error.log" do
  owner user
  group "wheel"
  mode "0640"
end

if sapi == "fpm"
  service "php-fpm" do
    supports :status => true, :restart => true
    action :enable
  end

  template "/etc/php/fpm-php5/php-fpm.conf" do
    source "#{php_version}/php-fpm.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "php-fpm")
  end

  nagios_service "PHP-FPM"
end

template "/etc/php/#{sapi}-php5/php.ini" do
  source "#{php_version}/php.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => service_name)
end

include_recipe "php::xcache"

syslog_config "90-php" do
  template "syslog.conf"
end

cookbook_file "/etc/logrotate.d/php" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end
