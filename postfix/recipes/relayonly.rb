include_recipe "postfix"

postconf "relay-only restrictions" do
  set :smtpd_client_restrictions => "permit_mynetworks, reject"
end
