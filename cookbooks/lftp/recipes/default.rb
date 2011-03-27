package "net-ftp/lftp"

template "/etc/lftp/lftp.conf" do
  source "lftp.conf"
  owner "root"
  group "root"
  mode "0644"
end

directory "/root/.lftp" do
  owner "root"
  group "root"
  mode "0700"
end

bookmarks = []

node[:lftp][:bookmarks].each do |name, url|
  bookmarks << "#{name} #{url}"
end

file "/root/.lftp/bookmarks" do
  content bookmarks.join("\n")
  owner "root"
  group "root"
  mode "0600"
end
