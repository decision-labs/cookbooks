description "Syslog Servers"

run_list(%w(
  role[base]
  recipe[postfix::satelite]
  recipe[syslog::server]
))

default_attributes({
  "munin" => {
    "group" => "logger"
  },
})
