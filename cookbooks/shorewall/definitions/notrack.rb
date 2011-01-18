define :shorewall_notrack,
  :source => "net",
  :dest => "$FW",
  :proto => "tcp",
  :destport => "-",
  :sourceport => "-" do
  node[:shorewall][:notrack][params[:name]] = params
end
