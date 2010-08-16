include_recipe "openssl"

%w(
  /etc/ssl/syslog-ng
  /etc/ssl/syslog-ng/ca.d
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0750"
    recursive true
  end
end

cookbook_file "/etc/ssl/syslog-ng/ca.d/ca.crt" do
  source "certificates/ca.crt"
  cookbook "openssl"
  owner "root"
  group "root"
  mode "0640"
end

execute "syslog-ca-symlink" do
  command "ln -s ca.crt /etc/ssl/syslog-ng/ca.d/`openssl x509 -noout -hash -in /etc/ssl/syslog-ng/ca.d/ca.crt`.0"
  not_if "test -e /etc/ssl/syslog-ng/ca.d/`openssl x509 -noout -hash -in /etc/ssl/syslog-ng/ca.d/ca.crt`.0"
end

ssl_certificate "/etc/ssl/syslog-ng/machine" do
  cn node[:fqdn]
  notifies :restart, resources(:service => "syslog-ng")
end
