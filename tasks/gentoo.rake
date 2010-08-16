require 'chef/search/query'

namespace :gentoo do
  desc "Update packages on gentoo nodes"
  task :updateworld do
    q = Chef::Search::Query.new
    q.search(:node, "platform:gentoo") do |node|
      puts ">>> #{node[:fqdn]}"
      system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -H /root/.bash/bin/updateworld'")
    end
  end
end
