begin
  include_recipe "node::#{node[:fqdn]}"
rescue
  # do nothing if node-specific recipe does not exist
end
