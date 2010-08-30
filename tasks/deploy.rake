desc "Upload cookbooks, roles and databags"
task :deploy => [ :init, :load_data_bags, :roles, :upload_cookbooks ]

desc "Converge all nodes"
task :converge do
  if not ENV.key?('QUERY')
    ENV['QUERY'] = "fqdn:[* TO *]"
  end
  Chef::Search::Query.new.search(:node, ENV['QUERY']) do |node|
    puts ">>> #{node[:fqdn]}"
    system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -H /usr/bin/chef-client -V'")
  end
end
