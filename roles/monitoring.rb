description "Monitoring Servers"

run_list(%w(
  role[base]
  recipe[postfix::satelite]
  recipe[nagios::server]
  recipe[munin::master]
))

default_attributes({
  "munin" => {
    "group" => "monitoring"
  }
})
