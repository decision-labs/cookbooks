search(:users, "tags:hostmaster") do |user|
  account_from_databag user.id

  group "wheel" do
    members user.id
    append true
  end
end
