default[:backup][:encryption_password] = 'sekrit'
default[:backup][:target_base_url] = "file:///backup"

set_unless[:backup][:configs] = Mash.new

node[:backup][:configs].each do |name, params|
  set[:backup][:configs][name][:name] = name
  set_unless[:backup][:configs][name][:max_full_backups] = 3
  set_unless[:backup][:configs][name][:max_full_age] = "1M"
  set_unless[:backup][:configs][name][:volume_size] = "25"
end
