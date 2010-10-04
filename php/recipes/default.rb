include_recipe "portage"
include_recipe "mysql::default"

portage_package_use "dev-lang/php" do
  use %w(-* bzip2 cgi cli crypt ctype curl exif fastbuild ftp fpm gd hash iconv json mysql mysqli nls pcre posix reflection session simplexml sockets spl ssl tokenizer truetype unicode xml zlib) + node[:php][:use_flags]
end

package "dev-lang/php"
package "dev-php5/xcache"

service "php-fpm" do
  supports :status => true
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

template "/etc/php/fpm-php5/php-fpm.conf" do
  source "php-fpm.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

%w(cgi fpm).each do |t|
  template "/etc/php/#{t}-php5/php.ini" do
    source "php.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "php-fpm")
  end

  template "/etc/php/#{t}-php5/ext/xcache.ini" do
    source "xcache.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "php-fpm")
  end

  link "/etc/php/#{t}-php5/ext-active/xcache.ini" do
    to "/etc/php/#{t}-php5/ext/xcache.ini"
  end
end
