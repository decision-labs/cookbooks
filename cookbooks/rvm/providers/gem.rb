include ChefUtils::RVM

action :install do
  rvm_gem_wrapper(new_resource, 'install')
end

action :uninstall do
  rvm_gem_wrapper(new_resource, 'uninstall')
end

def rvm_gem_wrapper(new_resource, _action)
  rvm = infer_vars(new_resource.user)
  name = new_resource.name

  version = if new_resource.version
              "-v #{new_resource.version}"
            else
              ""
            end

  use = if new_resource.use
          "rvm use #{new_resource.use}"
        else
          "true"
        end

  ifcode = <<-EOS
    su #{rvm[:user]} -l -c "source #{rvm[:path]}/scripts/rvm && #{use} && \
    gem query -i -n ^#{name}$ #{version} &>/dev/null"
  EOS

  e = rvm_execute "rvm/#{rvm[:user]}: gem #{_action} #{name}" do
    user rvm[:user]
    code "#{use} && gem #{_action} #{name} #{version}"
    action :nothing
    if _action == 'install'
      not_if ifcode
    else
      only_if ifcode
    end
  end

  e.run_action(:run)
end
