define :gitosis_repo do
  include_recipe "gitosis"

  execute "git-init-bare-#{params[:name]}" do
    command "/usr/bin/git-init-bare-empty /var/spool/gitosis/repositories/#{params[:name]}.git git git"
    creates "/var/spool/gitosis/repositories/#{params[:name]}.git"
  end
end
