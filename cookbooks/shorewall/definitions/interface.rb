define :shorewall_interface,
  :interface => nil do
  node[:shorewall][:interfaces][params[:name]] = params[:interface]
end
