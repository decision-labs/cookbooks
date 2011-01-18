define :shorewall_tunnel,
  :zone => nil,
  :gateway => nil do
  node[:shorewall][:tunnels][params[:name]] = params
end
