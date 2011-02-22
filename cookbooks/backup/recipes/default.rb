group "backup"
account_from_databag "backup"

ssh_chroot_sftp "backup" do
  directory "/backup"
end

search(:node, "backup_configs:[* TO *]") do |n|
  directory "/backup/#{n[:fqdn]}" do
    owner "backup"
    group "backup"
    mode "0700"
  end
end
