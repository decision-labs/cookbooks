hostmasters = data_bag('hostmasters')

hostmasters.each do |login|
  hostmaster = data_bag_item('hostmasters', login)

  account login do
    shell hostmaster['shell']
    comment hostmaster['comment']
    authorized_keys hostmaster['authorized_keys']
  end
end
