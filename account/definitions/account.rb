define :account,
       :uid => nil,
       :gid => "users",
       :groups => [],
       :shell => "/bin/bash",
       :comment => nil,
       :password => "!",
       :home => nil,
       :home_mode => "0750",
       :authorized_keys => [],
       :action => :create do
  include_recipe "account"

  home = params[:home]
  home = "/home/#{params[:name]}" if not home

  user params[:name] do
    uid params[:uid]
    gid params[:gid]
    shell params[:shell]
    comment params[:comment]
    password params[:password]
    home home
    action params[:action]
  end

  if params[:action] == :create
    params[:groups].each do |g|
      group g do
        members params[:name]
        append true
      end
    end

    home_owner = params[:name]
    home_group = params[:gid]
  else
    home_owner = "root"
    home_group = "root"
  end

  directory home do
    owner home_owner
    group home_group
    mode params[:home_mode]
  end

  directory "#{home}/.ssh" do
    owner home_owner
    group home_group
    mode "0700"
  end

  template "#{home}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    cookbook "account"
    owner home_owner
    group home_group
    mode "0600"
    variables(:authorized_keys => params[:authorized_keys])
  end
end

define :account_from_databag do
  user = search(:users, "id:#{params[:name]}").first
  account user[:id] do
    # TODO: meta magic is required here
    uid user[:uid] if user[:uid]
    gid user[:gid] if user[:gid]
    groups user[:groups] if user[:groups]
    shell user[:shell] if user[:shell]
    comment user[:comment] if user[:comment]
    password user[:password] if user[:password]
    home user[:home] if user[:home]
    home_mode user[:home_mode] if user[:home_mode]
    authorized_keys user[:authorized_keys] if user[:authorized_keys]
  end
end
