define :shorewall_zone,
  :type => "ipv4" do
  node[:shorewall][:zones][params[:name]] = params[:ztype]
end
