group "backup"
account_from_databag "backup"

node.set[:ssh][:server][:matches]["backup"] = {
  "match" => "User backup",
  "ChrootDirectory" => "/backup",
  "ForceCommand" => "internal-sftp",
  "X11Forwarding" => "no",
  "AllowTcpForwarding" => "no",
  "PasswordAuthentication" => "yes",
}

search(:node, "backup_configs:[* TO *]") do |n|
  directory "/backup/#{n[:fqdn]}" do
    owner "backup"
    group "backup"
    mode "0700"
  end
end
