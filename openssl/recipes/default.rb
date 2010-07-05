package "dev-libs/openssl"

template "/etc/ssl/openssl.cnf" do
  source "openssl.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
end
