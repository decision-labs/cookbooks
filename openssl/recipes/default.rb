package "dev-libs/openssl"

template "/etc/ssl/openssl.cnf" do
  source "openssl.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
end

if tagged?("nagios-client")
  nagios_plugin "ssl_cert" do
    source "check_ssl_cert"
  end
end
