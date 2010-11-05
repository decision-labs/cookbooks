include_recipe "postfix"

postconf "TLS encryption" do
  set :smtpd_tls_cert_file => "/etc/ssl/postfix/server.crt",
      :smtpd_tls_key_file => "/etc/ssl/postfix/server.key",
      :smtpd_tls_security_level => "may",
      :smtpd_tls_auth_only => "yes",
      :smtpd_tls_session_cache_database => "btree:/var/lib/postfix/smtpd_scache",
      :smtpd_tls_session_cache_timeout => "3600s"
end

# nagios service checks
if tagged?("nagios-client")
  node.default[:nagios][:services]["POSTFIX-TLS"][:enabled] = true
end
