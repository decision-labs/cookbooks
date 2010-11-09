include_recipe "portage"
include_recipe "mysql::default"

portage_package_use "dev-lang/php" do
  use %w(-* bzip2 cgi cli crypt ctype curl exif filter ftp fpm gd hash iconv json mysql mysqli nls pcre pdo posix reflection session simplexml sockets spl ssl tokenizer truetype unicode xml zlib) + node[:php][:use_flags]
end

package "dev-lang/php"

service "php-fpm" do
  supports :status => true, :restart => true
  action :enable
end

[
  node[:php][:tmp_dir],
  node[:php][:upload][:tmp_dir],
  node[:php][:session][:save_path]
].each do |p|
  directory p do
    owner node[:php][:fpm][:user]
    group node[:php][:fpm][:group]
    mode "0750"
  end
end

file "/var/log/php-error.log" do
  owner node[:php][:fpm][:user]
  group "wheel"
  mode "0640"
end

template "/etc/php/fpm-php5/php-fpm.conf" do
  source "php-fpm.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

template "/etc/php/fpm-php5/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
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

nagios_service "PHP-FPM"
