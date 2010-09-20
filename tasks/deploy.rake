desc "Upload cookbooks, roles and databags"
task :deploy => [ :init, "load:all" ]
