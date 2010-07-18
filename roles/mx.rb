name "mx"
description "Mail Relay Servers"

run_list << "role[base]"

%w(
  postfix::relay
).each do |r|
  run_list << "recipe[#{r}]"
end
