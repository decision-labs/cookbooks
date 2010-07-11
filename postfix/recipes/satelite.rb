include_recipe "postfix::adminforward"
include_recipe "postfix::smtpd"

postconf "relay all mail via relayhost" do
  set :relayhost => node[:postfix][:relayhost],
      :inet_interfaces => "loopback-only"
end
