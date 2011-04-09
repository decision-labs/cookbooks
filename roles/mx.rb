description "Mail Relay Servers"

run_list(%w(
  role[base]
  recipe[postfix::relay]
))

default_attributes({
  "munin" => {
    "group" => "mx"
  },
})

override_attributes({
  "skip" => {
    "postfix_satelite" => true,
  },
})
