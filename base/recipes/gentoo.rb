include_recipe "portage"

portage_pkg "sys-apps/baselayout" do
  keywords %w(~sys-apps/baselayout-2.0.1)
end

portage_pkg "sys-apps/openrc" do
  keywords %w(~sys-apps/openrc-0.6.1)
end

%w(
  app-admin/pwgen
  app-admin/pydf
  app-arch/atool
  app-arch/xz-utils
  app-editors/vim
  app-misc/colordiff
  app-misc/mc
  app-misc/screen
  app-misc/tmux
  dev-vcs/git
  net-analyzer/bwm-ng
  net-analyzer/mtr
  net-analyzer/tcpdump
  net-analyzer/traceroute
  net-dns/bind-tools
  net-misc/keychain
  net-misc/rsync
  net-misc/telnet-bsd
  net-misc/wget
  sys-apps/iproute2
  sys-apps/pciutils
  sys-fs/ncdu
  sys-process/htop
  sys-process/iotop
  sys-process/lsof
).each do |pkg|
  package pkg
end

cookbook_file "/etc/profile.d/prompt.sh" do
  source "prompt.sh"
  mode "0644"
  backup 0
end

%w(
  /etc/init.d/net.lo
  /etc/init.d/net.eth0
  /etc/init.d/net.eth1
  /etc/runlevels/boot/net.lo
  /etc/runlevels/boot/net.eth0
  /etc/runlevels/boot/net.eth1
  /etc/runlevels/default/net.lo
  /etc/runlevels/default/net.eth0
  /etc/runlevels/default/net.eth1
  /etc/conf.d/net
).each do |f|
  file f do
    action :delete
    backup 0
  end
end

cookbook_file "/etc/ifup.eth0" do
  source "ifup.eth0"
  mode "0644"
end

cookbook_file "/etc/ifup.eth1" do
  source "ifup.eth1"
  mode "0644"
end

case node[:virtualization][:role]
when "guest"
  file "/etc/init.d/shutdown.sh" do
    content "exit 0\n"
    mode "0755"
    backup 0
  end

  file "/etc/init.d/reboot.sh" do
    content "exit 0\n"
    mode "0755"
    backup 0
  end
else
  %w(shutdown reboot).each do |t|
    cookbook_file "/etc/init.d/#{t}.sh" do
      source "#{t}.sh"
      mode "0755"
      backup 0
    end
  end
end

%w(hostname hwclock).each do |f|
  template "/etc/conf.d/#{f}" do
    source "#{f}.confd"
    mode "0644"
    backup 0
  end
end

%w(devfs dmesg udev).each do |f|
  link "/etc/runlevels/sysinit/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(
  bootmisc
  consolefont
  fsck
  hostname
  hwclock
  keymaps
  localmount
  modules
  mtab
  network
  procfs
  root
  swap
  sysctl
  termencoding
  urandom
).each do |f|
  link "/etc/runlevels/boot/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(local netmount).each do |f|
  link "/etc/runlevels/default/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(killprocs mount-ro savecache).each do |f|
  link "/etc/runlevels/shutdown/#{f}" do
    to "/etc/init.d/#{f}"
  end
end
