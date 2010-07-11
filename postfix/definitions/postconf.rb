# postconf "satelite" do
#   set :relayhost => "mail.foo.com",
#       :inet_interfaces => loopback-only
# end

define :postconf, :set => {} do
  include_recipe "postfix"

  t = nil
  begin
    t = resources(:template => "/etc/postfix/main.cf")
  rescue ArgumentError
    t = template "/etc/postfix/main.cf" do
      source "main.cf.erb"
      cookbook "postfix"
      owner "root"
      group "root"
      mode "0644"
      variables({:sections => {}})
      notifies :restart, resources(:service => "postfix")
    end
  end

  t.variables[:sections][params[:name]] = params[:set]
end
