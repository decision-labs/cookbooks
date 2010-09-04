# remote commands for maintenance

def rc(default_query)
  ENV['QUERY'] = default_query if not ENV.key?('QUERY')
  Chef::Search::Query.new.search(:node, ENV['QUERY']) do |node|
    puts ">>> #{node[:fqdn]}"
    yield node
  end
end

namespace :rc do

  desc "Update gentoo packages"
  task :updateworld do
    rc "platform:gentoo" do |node|
      system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -H /root/.bash/bin/updateworld'")
    end
  end

  desc "Open root shell"
  task :root do
    rc "fqdn:[* TO *]" do |node|
      system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -Hi'")
    end
  end

  desc "Run chef-client"
  task :converge do
    rc "fqdn:[* TO *]" do |node|
      system("ssh -t #{node[:fqdn]} '/usr/bin/sudo -H /usr/bin/chef-client -V'")
    end
  end

  desc "Run custom script"
  task :script do
    raise "SCRIPT must be supplied" if not ENV.key?('SCRIPT')
    raise "SCRIPT='#{ENV['SCRIPT']}' not found" if not File.exist?(ENV['SCRIPT'])
    rc "fqdn:[* TO *]" do |node|
      system("cat '#{ENV['SCRIPT']}' | ssh #{node[:fqdn]} 'bash -s'")
    end
  end
end
