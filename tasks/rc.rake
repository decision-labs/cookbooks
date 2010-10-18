# remote commands for maintenance

def rc(default_query)
  ENV['QUERY'] = default_query if not ENV.key?('QUERY')
  Chef::Search::Query.new.search(:node, ENV['QUERY'], 'fqdn asc') do |node|
    puts ">>> #{node.name}"
    yield node
  end
end

namespace :rc do

  desc "Update gentoo packages"
  task :updateworld do
    rc "platform:gentoo" do |node|
      system("ssh -t #{node.name} '/usr/bin/sudo -H /root/.bash/bin/updateworld'")
    end
  end

  desc "Run chef-client"
  task :converge do
    rc "name:[* TO *]" do |node|
      system("ssh -t #{node.name} '/usr/bin/sudo -H /usr/bin/chef-client -V'")
    end
  end

  desc "Open interactive shell"
  task :shell do
    rc "name:[* TO *]" do |node|
      if ENV.key?('NOSUDO')
        system("ssh -t #{node.name}'")
      else
        system("ssh -t #{node.name} '/usr/bin/sudo -Hi'")
      end
    end
  end

  desc "Run custom script"
  task :script do
    raise "SCRIPT must be supplied" if not ENV.key?('SCRIPT')
    script = File.join(TOPDIR, 'scripts', ENV['SCRIPT'])
    raise "SCRIPT='#{ENV['SCRIPT']}' not found" if not File.exist?(script)
    rc "name:[* TO *]" do |node|
      if ENV.key?('NOSUDO')
        system("cat '#{script}' | ssh #{node.name} '/bin/bash -s'")
      else
        system("cat '#{script}' | ssh #{node.name} '/usr/bin/sudo -H /bin/bash -s'")
      end
    end
  end

  desc "Run custom command"
  task :cmd do
    raise "CMD must be supplied" if not ENV.key?('CMD')
    rc "name:[* TO *]" do |node|
      if ENV.key?('NOSUDO')
        system("ssh -t #{node.name} '#{ENV['CMD']}'")
      else
        system("ssh -t #{node.name} '/usr/bin/sudo -H #{ENV['CMD']}'")
      end
    end
  end
end
