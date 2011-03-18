define :shorewall_host,
  :options => "-" do
  node[:shorewall][:hosts][params[:name]] = params
end
