require 'chef/search/query'

namespace :gentoo do
  desc "Update packages on gentoo nodes"
  task :updateworld do
    Chef::Search::Query.new.search(:node, "platform:gentoo") do |node|
      puts ">>> #{node[:fqdn]}"
      system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -H /root/.bash/bin/updateworld'")
    end
  end
end
