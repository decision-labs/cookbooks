desc "Upload cookbooks, roles and databags"
task :deploy => [ "pull", "load:all" ]
