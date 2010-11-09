include_recipe "postfix"
include_recipe "openssl"

ssl_ca "/etc/ssl/postfix/ca" do
  notifies :restart, resources(:service => "postfix")
end

ssl_certificate "/etc/ssl/postfix/server" do
  cn node[:fqdn]
  notifies :restart, resources(:service => "postfix")
end

postconf "TLS encryption" do
  set :smtpd_tls_cert_file => "/etc/ssl/postfix/server.crt",
      :smtpd_tls_key_file => "/etc/ssl/postfix/server.key",
      :smtpd_tls_CAfile => "/etc/ssl/postfix/ca.crt",
      :smtpd_tls_security_level => "may",
      :smtpd_tls_auth_only => "yes",
      :smtpd_tls_session_cache_database => "btree:/var/lib/postfix/smtpd_scache",
      :smtpd_tls_session_cache_timeout => "3600s"
end

nagios_service "POSTFIX-TLS"
