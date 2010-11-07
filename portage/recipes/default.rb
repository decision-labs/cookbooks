link "/etc/make.profile" do
  to node[:portage][:profile]
end

directory node[:portage][:confdir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d #{node[:portage][:confdir]}"
end

%w(keywords mask unmask use).each do |type|
  path = "#{node[:portage][:confdir]}/package.#{type}"

  execute "backup-package.#{type}" do
    command "mv #{path} #{path}.bak"
    only_if "test -f #{path}"
  end

  directory path do
    owner "root"
    group "root"
    mode "0755"
    action :create
    not_if "test -d #{path}"
  end

  execute "restore-package.#{type}" do
    command "mv #{path}.bak #{path}/local"
    only_if "test -f #{path}.bak"
  end
end

directory "#{node[:portage][:make_conf]}.d" do
  owner "root"
  group "root"
  mode "755"
  action :create
  not_if "test -d #{node[:portage][:make_conf]}.d"
end

template "#{node[:portage][:make_conf]}.d/local.conf" do
  owner "root"
  group "root"
  mode "644"
  source "make.conf.local.erb"
  backup 0
end

template node[:portage][:make_conf] do
  owner "root"
  group "root"
  mode "644"
  source "make.conf.erb"
  cookbook "portage"
  variables({:sources => []})
  backup 0
end

portage_package_keywords "=sys-apps/portage-2.2*" do
  keywords "**"
end

portage_package_unmask "=sys-apps/portage-2.2*" do
  action :delete
end

package "sys-apps/portage"

%w(autounmask eix elogv gentoolkit portage-utils).each do |pkg|
  package "app-portage/#{pkg}"
end

execute "eix-update" do
  only_if do
    doit = false

    check_files = Dir.glob("/var/lib/layman/*/.git/index")
    check_files << "/usr/portage/metadata/timestamp.chk"

    check_files.each do |f|
      doit = true if test ?>, f, "/var/cache/eix"
    end

    doit
  end
end

cookbook_file "/etc/logrotate.d/portage" do
  source "portage.logrotate"
  mode "0644"
  backup 0
end

directory node[:portage][:distdir] do
  owner "root"
  group "portage"
end

cookbook_file "/etc/dispatch-conf.conf" do
  source "dispatch-conf.conf"
  mode "0644"
  backup 0
end
