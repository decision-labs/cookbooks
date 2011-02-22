define :ssh_chroot_sftp do
  include_recipe "ssh"

  node.set[:ssh][:server][:matches]["chroot_sftp_#{params[:name]}"] = {
    "match" => "User #{params[:name]}",
    "ChrootDirectory" => params[:directory],
    "ForceCommand" => "internal-sftp",
    "X11Forwarding" => "no",
    "AllowTcpForwarding" => "no",
    "PasswordAuthentication" => "yes",
  }
end
