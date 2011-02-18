require 'chef/node'
require 'chef/data_bag'
require 'chef/data_bag_item'

task :require_clean_working_tree do
  sh "git update-index -q --ignore-submodules --refresh"
  err = false

  sh "git diff-files --quiet --ignore-submodules --" do |ok, res|
    unless ok
      err = true
      puts "\n** working tree contains unstaged changes:"
      sh "git diff-files --name-status -r --ignore-submodules -- >&2"
    end
  end

  sh "git diff-index --cached --quiet HEAD --ignore-submodules --" do |ok, res|
    unless ok
      err = true
      puts "\n** index contains uncommited changes:"
      sh "git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2"
      puts ""
    end
  end

  err and fail "Working tree is dirty (stash or commit changes)"
end

desc "Pull changes from the remote repository"
task "pull" => :require_clean_working_tree
task "pull" do
  sh "git checkout master"
  sh "git pull"
end

namespace "load" do

  desc "Load all entities"
  task "all" => [ :cookbooks, :nodes, :roles, :databags ]

  desc "Load cookbooks"
  task "cookbooks" do
    system("knife cookbook metadata --all")
    system("knife cookbook upload --all")
  end

  desc "Purge and load all cookbooks"
  task "cookbooks_clear" do
    rest = Chef::REST.new(Chef::Config[:chef_server_url])
    rest.get_rest('cookbooks').keys.each do |cb|
      puts "Deleting cookbook #{cb} ..."
      rest.get_rest("cookbooks/#{cb}").values.flatten.each do |v|
        puts "  v#{v}"
        rest.delete_rest("cookbooks/#{cb}/#{v}")
      end
    end
    system("rm -rf #{Chef::Config[:cache_options][:path]}")
    system("knife cookbook metadata --all")
    system("knife cookbook upload --all")
  end

  desc "Load node definitions"
  task "nodes" do
    nodes_dir = File.join(TOPDIR, "nodes")
    nodes = Dir[ File.join(nodes_dir, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    existing = Chef::Node.list

    nodes.each do |node|
      if existing.include?(node)
        puts "Updating node #{node} ..."
        n = Chef::Node.load(node)
      else
        puts "Creating node #{node} ..."
        n = Chef::Node.new
        n.name(node)
      end

      n.from_file(File.join(nodes_dir, "#{node}.rb"))
      n.save
    end
  end

  desc "Load roles"
  task "roles" do
    roles_dir = File.join(TOPDIR, "roles")
    roles = Dir[ File.join(roles_dir, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    existing = Chef::Role.list

    roles.each do |role|
      if existing.include?(role)
        puts "Updating role #{role} ..."
      else
        puts "Creating role #{role} ..."
      end

      r = Chef::Role.new
      r.name(role)
      r.from_file(File.join(roles_dir, "#{role}.rb"))
      r.save
    end
  end

  desc "Load data bags"
  task "databags" do
    bags_dir = File.join(TOPDIR, "databags")
    bags = Dir[ File.join(bags_dir, "*/") ].map do |f|
      File.basename(f)
    end.sort!

    existing = Chef::DataBag.list

    bags.each do |bag|
      puts "Uploading data bag #{bag} ..."

      if existing.include?(bag)
        b = Chef::DataBag.load(bag)
      else
        b = Chef::DataBag.new
        b.name(bag)
        b.create
      end

      items = Dir[ File.join(bags_dir, bag, "*.rb") ].map do |f|
        File.basename(f, '.rb')
      end.sort!

      items.each do |item|
        puts "  > #{item}"

        i = Chef::DataBagItem.new
        i.data_bag(bag)
        i[:id] = item

        i.create if not b.include?(item)
        i.from_file(File.join(bags_dir, bag, "#{item}.rb"))
        i.save
      end
    end
  end

end

desc "Upload cookbooks, roles and databags"
task :deploy => [ "pull", "load:all" ]
