include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name, new_resource.version)

  file rvm[:rvmrc] do
    action :delete
  end

  bash "install rvm-#{rvm[:version]}" do
    code <<-EOS
    export USER=#{rvm[:user]}
    export HOME=#{rvm[:homedir]}

    tmpfile=$(mktemp)
    curl -s https://rvm.beginrescueend.com/install/rvm -o ${tmpfile}
    chmod +x ${tmpfile}
    ${tmpfile} #{rvm[:version]}
    rm -f ${tmpfile}
    EOS

    creates "#{rvm[:path]}/src/rvm-#{rvm[:version]}"
    user rvm[:user]
    group rvm[:group]
  end

  directory "#{rvm[:path]}/hooks" do
    owner rvm[:user]
    group rvm[:group]
    mode "0755"
  end

  file "#{rvm[:path]}/hooks/after_install" do
    content "# needed for idempotency in fake-vardb\ntouch #{rvm[:path]}/.last_install_action"
    owner rvm[:user]
    group rvm[:group]
    mode "0644"
  end
end

action :delete do
  rvm = infer_vars(new_resource.user)

  directory rvm[:path] do
    action :delete
    recursive true
  end
end
