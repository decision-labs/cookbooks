name "monitoring"
description "Monitoring Servers"

run_list(%w(
  role[base]
  recipe[postfix::satelite]
  recipe[nagios::server]
))
