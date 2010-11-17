define :shorewall_policy,
  :source => nil,
  :dest => nil,
  :policy => nil do
  node[:shorewall][:policies][params[:name]] = params
end
