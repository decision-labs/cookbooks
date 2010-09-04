desc "Upload cookbooks, roles and databags"
task :deploy => [ :init, :load_data_bags, :roles, :upload_cookbooks ]
