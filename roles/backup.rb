description "Backup Server"

# order is very important here!
run_list(%w(
  role[base]
  recipe[backup]
))
