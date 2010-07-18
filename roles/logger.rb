name "logger"
description "Syslog Servers"

run_list << "role[base]"

%w(
  postfix::satelite
  syslog::server
).each do |r|
  run_list << "recipe[#{r}]"
end
