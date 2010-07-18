name "monitoring"
description "Monitoring Servers"

run_list << "role[base]"

%w(
  postfix::satelite
  nagios::server
).each do |r|
  run_list << "recipe[#{r}]"
end
