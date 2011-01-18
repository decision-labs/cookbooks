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

[
  node[:php][:tmp_dir],
  node[:php][:upload][:tmp_dir],
  node[:php][:session][:save_path]
].each do |p|
  directory p do
    owner "root"
    group "root"
    mode "1777"
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

  template "/etc/php/fpm-php#{PHP.slot}/php-fpm.conf" do
    source "#{PHP.slot}/php-fpm.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "php-fpm")
  end

  nrpe_command "check_php_fpm" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/php-fpm.pid php-fpm"
  end

  nagios_service "PHP-FPM" do
    check_command "check_nrpe!check_php_fpm"
  end
end

template "/etc/php/#{sapi}-php#{PHP.slot}/php.ini" do
  source "#{PHP.slot}/php.ini"
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
