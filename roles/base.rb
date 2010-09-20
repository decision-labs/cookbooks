name "base"
description "base role for all nodes"

# order is very important here!
%w(
  portage::layman
  portage
  portage::porticron
  base
  openssl
  password
  nss::local
  syslog::client
  cron
  sudo
  ssh
  account
  account::hostmasters
  chef::client
  nagios::client
  node::default
).each do |r|
  run_list << "recipe[#{r}]"
end
