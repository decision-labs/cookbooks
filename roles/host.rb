name "host"
description "Linux-VServer Hosts"

run_list << "role[base]"

%w(
  mdadm
  ntp
  pkgsync
  postfix::satelite
  shorewall
  smart
  vserver
).each do |r|
  run_list << "recipe[#{r}]"
end
