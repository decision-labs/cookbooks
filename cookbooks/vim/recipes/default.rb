package "app-editors/vim"

cookbook_file "/etc/vim/vimrc.local" do
  source "vimrc"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/usr/local/bin/mvim" do
  source "mvim"
  owner "root"
  group "root"
  mode "0755"
end
