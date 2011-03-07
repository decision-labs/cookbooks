package "app-misc/tmux"

cookbook_file "/etc/tmux.conf" do
  source "tmux.conf"
  owner "root"
  group "root"
  mode "0644"
end
