define :account, :uid => nil, :gid => nil, :shell => nil, :comment => nil, :home_mode => "0750", :authorized_keys => [] do
  home = "/home/#{params[:name]}"

  user params[:name] do
    shell params['shell']
    comment params['comment']
    home home
  end

  directory home do
    owner params[:name]
    group "users"
    mode params[:home_mode]
  end

  directory "#{home}/.ssh" do
    owner params[:name]
    group "users"
    mode "0700"
  end

  template "#{home}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    cookbook "account"
    owner params[:name]
    group "users"
    mode "0600"
    variables(:authorized_keys => params[:authorized_keys])
  end
end
