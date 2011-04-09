description "Chef Servers"

run_list(%w(
  role[base]
  recipe[chef::server]
  recipe[pkgsync::master]
))

default_attributes({
  "munin" => {
    "group" => "chef"
  },
})
