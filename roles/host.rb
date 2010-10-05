name "host"
description "Linux-VServer Hosts"

run_list(%w(
  role[base]
  recipe[mdadm]
  recipe[ntp]
  recipe[pkgsync]
  recipe[postfix::satelite]
  recipe[shorewall]
  recipe[smart]
  recipe[vserver]
))
