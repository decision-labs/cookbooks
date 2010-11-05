include_recipe "postfix"
include_recipe "postfix::adminforward"
include_recipe "postfix::tls"

postconf "relay all mail via relayhost" do
  set :relayhost => node[:postfix][:relayhost],
      :inet_interfaces => "loopback-only"
end

# nagios service checks
if tagged?("nagios-client")
  node.default[:nagios][:nrpe][:commands][:check_postfix_satelite] = "/usr/lib/nagios/plugins/check_smtp -H #{node[:postfix][:relayhost]} -t 3 -C 'MAIL FROM: <root@#{node[:fqdn]}>' -R '250 2.1.0 Ok' -C 'RCPT TO: <unhollow@gmail.com>' -R '250 2.1.5 Ok'"
  node.default[:nagios][:services]["POSTFIX-SATELITE"][:enabled] = true
end
