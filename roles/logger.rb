name "logger"
description "Syslog Servers"

run_list(%w(
  role[base]
  recipe[postfix::satelite]
  recipe[syslog::server]
))
