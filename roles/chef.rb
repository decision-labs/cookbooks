name "chef"
description "Chef Servers"

run_list << "role[base]"

%w(
  postfix::satelite
  chef::server
  pkgsync::master
).each do |r|
  run_list << "recipe[#{r}]"
end
