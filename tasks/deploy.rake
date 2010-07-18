desc "Install and deploy locally"
task :deploy => [ :install, :load_data_bags ]
