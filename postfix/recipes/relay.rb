include_recipe "postfix"
include_recipe "postfix::adminforward"
include_recipe "postfix::relayhost"
include_recipe "postfix::tls"

postconf "relay-only restrictions" do
  set :smtpd_client_restrictions => "permit_mynetworks, reject"
end
