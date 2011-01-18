package "app-shells/bash"

%w(
  bash_logout
  bashcomp-modules
  bashcomp.sh
  bashrc
  color.sh
  detect.sh
  gentoo.sh
  prompt.sh
).each do |f|
  cookbook_file "/etc/bash/#{f}" do
    source f
    owner "root"
    group "root"
    mode "0644"
  end
end

%w(
  Find
  IP
  copy
  grab
  mktar
  urlscript
).each do |f|
  cookbook_file "/usr/local/bin/#{f}" do
    source "scripts/#{f}"
    owner "root"
    group "root"
    mode "0755"
  end
end
