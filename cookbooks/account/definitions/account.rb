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

  group params[:gid] do
    append true
  end

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

  directory File.dirname(home) do
    owner "root"
    group "root"
    mode "0755"
    recursive true
    not_if "test -d #{File.dirname(home)}"
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
    user.each do |k, v|
      next if k.to_s == "id"
      v ||= params[k]
      send k.to_sym, v if v
    end
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
