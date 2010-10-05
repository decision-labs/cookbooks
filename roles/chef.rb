name "chef"
description "Chef Servers"

run_list(%w(
  role[base]
  recipe[postfix::satelite]
  recipe[chef::server]
  recipe[pkgsync::master]
))
