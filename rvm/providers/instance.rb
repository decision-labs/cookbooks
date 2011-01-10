include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name, new_resource.version)

  file rvm[:rvmrc] do
    content <<-EOS
rvm_selfcontained=1
rvm_prefix=#{::File.dirname(rvm[:path])}
rvm_path=#{rvm[:path]}
EOS
    owner rvm[:user]
    group rvm[:group]
    mode "0644"
  end

  bash "install rvm-#{rvm[:version]}" do
    code <<-EOS
    export HOME=#{rvm[:homedir]}
    export rvm_path="#{rvm[:path]}"
    stable_version=#{rvm[:version]}

    mkdir -p ${rvm_path}/src
    builtin cd ${rvm_path}/src

    curl -L "http://rvm.beginrescueend.com/releases/rvm-${stable_version}.tar.gz" -o "rvm-${stable_version}.tar.gz"
    tar zxf "rvm-${stable_version}.tar.gz"

    builtin cd "rvm-${stable_version}"
    bash ./scripts/install
    EOS

    creates "#{rvm[:path]}/src/rvm-#{rvm[:version]}"
    user rvm[:user]
    group rvm[:group]
  end

  file "#{rvm[:path]}/gemsets/global.gems" do
    content "bundler\n"
    owner rvm[:user]
    group rvm[:group]
    mode "0644"
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
