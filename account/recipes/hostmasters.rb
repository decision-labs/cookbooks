hostmasters = data_bag('hostmasters')

hostmasters.each do |login|
  hostmaster = data_bag_item('hostmasters', login)

  account login do
    password hostmaster['password']
    shell hostmaster['shell']
    comment hostmaster['comment']
    authorized_keys hostmaster['authorized_keys']
  end

  group "wheel" do
    members login
    append true
  end
end
