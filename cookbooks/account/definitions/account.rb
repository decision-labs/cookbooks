define :account,
       :uid => nil,
       :gid => "users",
       :groups => [],
       :shell => "/bin/bash",
       :comment => nil,
       :password => "!",
       :home => nil,
       :home_mode => "0750",
       :home_owner => nil,
       :home_group => nil,
       :authorized_keys => [],
       :action => :create do
  include_recipe "account"

  home = params[:home]
  home ||= "/home/#{params[:name]}"

  home_owner = params[:home_owner]
  home_group = params[:home_group]

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

    home_owner ||= params[:name]
    home_group ||= params[:gid]
  else
    home_owner ||= "root"
    home_group ||= "root"
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
  
  # don't create a authorized keys file if authorized_keys is nil, if it's empty
  # i.e. [], then we would create an empty authorized keys but with nil, the file
  # is not created.
  unless params[:authorized_keys].nil?
    template "#{home}/.ssh/authorized_keys" do
      source "authorized_keys.erb"
      cookbook "account"
      owner home_owner
      group home_group
      mode "0600"
      variables(:authorized_keys => params[:authorized_keys])
    end
  end
end

define :account_from_databag,
  :databag => :users do
  user = search(params[:databag], "id:#{params[:name]}").first
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
    home_owner user[:home_owner] if user[:home_owner]
    home_group user[:home_group] if user[:home_group]
    authorized_keys user[:authorized_keys] if user[:authorized_keys]
  end
end

define :accounts_from_databag,
  :groups => [],
  :databag => :users do
  search(params[:databag], params[:name]) do |user|
    account_from_databag user[:id] do
      databag params[:databag]
    end

    params[:groups].each do |g|
      group g do
        members user[:id]
        append true
      end
    end
  end
end