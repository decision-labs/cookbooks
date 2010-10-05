name "mx"
description "Mail Relay Servers"

run_list(%w(
  role[base]
  recipe[postfix::relay]
))
