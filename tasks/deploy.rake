desc "Upload cookbooks, roles and databags"
task :deploy => [ :init, :install, :load_data_bags ]
