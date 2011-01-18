# postconf "satelite" do
#   set :relayhost => "mail.foo.com",
#       :inet_interfaces => loopback-only
# end

define :postmaster, :stype => "unix", :priv => "-", :unpriv => "-", :chroot => "n", :wakeup => "-", :maxproc => "-", :command => nil, :args => nil do
  include_recipe "postfix"

  t = nil
  begin
    t = resources(:template => "/etc/postfix/master.cf")
  rescue ArgumentError, Chef::Exceptions::ResourceNotFound
    t = template "/etc/postfix/master.cf" do
      source "master.cf.erb"
      cookbook "postfix"
      owner "root"
      group "root"
      mode "0644"
      variables({:services => []})
      notifies :restart, resources(:service => "postfix")
    end
  end

  t.variables[:services] << params
end
