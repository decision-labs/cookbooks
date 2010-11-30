include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.user)

  file new_resource.name do
    content <<-EOS
#!/bin/bash
export HOME=#{rvm[:homedir]}
source #{rvm[:path]}/scripts/rvm
#{new_resource.code}
EOS
    owner rvm[:user]
    group rvm[:group]
    mode new_resource.mode
  end
end

action :delete do
  file new_resource.name do
    action :delete
  end
end
