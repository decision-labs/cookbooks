require 'chef/node'

def knife
  return @knife if @knife

  chef_config_file = File.join(ENV['HOME'], '.chef', 'knife.rb')
  @knife = Chef::Knife.new 
  @knife.config[:config_file] = chef_config_file
  @knife.configure_chef
  @knife
end

def rest; knife.rest end

namespace "load" do

  desc "Load node definitions"
  task "nodes" do
    nodes_dir = File.join(TOPDIR, "nodes")
    nodes = Dir[ File.join(nodes_dir, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end

    existing = Chef::Node.list

    nodes.each do |node|
      # create if missing
      if existing.include?(node)
        puts "Updating node #{node} ..."
        n = Chef::Node.load(node)
      else
        puts "Creating node #{node} ..."
        n = Chef::Node.new
        n.name(node)
      end

      # update
      n.from_file(File.join(nodes_dir, "#{node}.rb"))

      # save
      n.save
    end
  end

  # TODO: use DataBag interface
  desc "Load data bags"
  task :data_bags do
    bags_dir = File.join(TOPDIR, "databags")

    bag_ids = JSON.parse %x(knife data bag list)
    files = Dir[ File.join(bags_dir, '*.json') ].map {|f| 
      File.basename(f, '.json')
    }

    new_bags = files - bag_ids
    missing_files = bag_ids - files
    bag_ids_to_update = files

    new_bags.each do |new_bag_id|
      system "knife data bag create #{new_bag_id}"
    end

    if ! missing_files.empty? then
      puts "Following bags don't have files to load: %s" % 
        missing_files.join(', ')
    end

    bag_ids_to_update.each do |bag_id|
      fullname = File.join(bags_dir, bag_id) + '.json'
      json = File.read(fullname)
      content = JSON.parse json
      raise "array of items expected: #{json}" unless content.is_a?(Array)

      item_hash = content.inject({}) do |h,item| 
        raise "item missing id: %s" % JSON.pretty_generate(item) unless 
          item['id']
        h[item['id']] = item
        h
      end

      # file_item_ids = content.map{|item| item['id']}
      file_item_ids = item_hash.keys.sort
      item_ids = JSON.parse %x(knife data bag show #{bag_id})

      item_ids_with_bad_ids = file_item_ids.select {|item_id| item_id !~ /^\w(\w|[-_])+$/ }
      unless item_ids_with_bad_ids.empty?
        raise "ERROR: item ids have invalid names: %s" % item_ids_with_bad_ids.join(' ')
      end

      ids_to_delete = item_ids - file_item_ids
      ids_to_create = file_item_ids - item_ids
      ids_to_update = item_ids & file_item_ids

      ids_to_update.each do |item_id|
        item_url = "data/#{bag_id}/#{item_id}"

        if item_hash[item_id] == rest.get_rest(item_url) then
          puts "skipping #{item_url}"
        else
          puts "updating #{item_url}"
          rest.put_rest(item_url, item_hash[item_id])
        end
      end
      ids_to_create.each do |item_id|
        puts "creating #{bag_id}/#{item_id}"
        rest.post_rest("data/#{bag_id}", item_hash[item_id])
      end
      ids_to_delete.each do |item_id|
        puts "deleting #{bag_id}/#{item_id}"
        rest.delete_rest("data/#{bag_id}/#{item_id}")
      end
    end
  end

end

namespace "dump" do

  desc "Dump data bags"
  task :data_bags do
    # TODO: replace with direct REST access
    bags_dir = File.join(TOPDIR, "databags")
    Dir.mkdir bags_dir unless File.directory? bags_dir

    bag_ids = JSON.parse %x(knife data bag list)
    bag_ids.sort.each do |bag_id|
      item_ids = JSON.parse %x(knife data bag show #{bag_id})
      items_j = item_ids.map do |item_id|
        %x( knife data bag show #{bag_id} #{item_id})
      end
      items = items_j.map {|j| JSON.parse j }
      # TODO: limit number of backups
      fullname = File.join(bags_dir, bag_id) + '.json'
      time_suffix = Time.new.strftime("%Y%m%d_%H%M%S")
      File.rename(fullname, fullname+'.'+time_suffix) if File.exists?(fullname)

      File.open(fullname, 'w') do |out|
        out << JSON.pretty_generate(items)
        out << "\n"
      end
    end
  end

end
