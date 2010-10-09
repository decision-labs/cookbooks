include_recipe "postfix"
include_recipe "postfix::adminforward"

postconf "relay all mail via relayhost" do
  set :relayhost => node[:postfix][:relayhost],
      :inet_interfaces => "loopback-only"
end
