include_recipe "portage"
include_recipe "portage::layman"

execute "layman-chef" do
  command "layman -f -a chef"
  not_if "test -d #{node[:portage][:layman][:storage]}/chef"
end
