define :shorewall6_rule,
  :action => "ACCEPT",
  :source => "net",
  :dest => "$FW",
  :proto => "tcp",
  :destport => "-",
  :sourceport => "-" do
  node[:shorewall][:rules6][params[:name]] = params
end
