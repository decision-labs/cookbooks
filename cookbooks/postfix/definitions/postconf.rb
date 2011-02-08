# postconf "satelite" do
#   set :relayhost => "mail.foo.com",
#       :inet_interfaces => loopback-only
# end

# for 0.9.8 compatibility
class Chef::Exceptions::ResourceNotFound
end

define :postconf, :set => {} do
  include_recipe "postfix"

  t = nil
  begin
    t = resources(:template => "/etc/postfix/main.cf")
  rescue ArgumentError, Chef::Exceptions::ResourceNotFound
    t = template "/etc/postfix/main.cf" do
      source "main.cf.erb"
      cookbook "postfix"
      owner "root"
      group "root"
      mode "0644"
      variables({:sections => {}})
      notifies :restart, "service[postfix]"
    end
  end

  # inject() will convert Symbol keys into Strings to make the Hash sortable. Yep, it's ugly.
  t.variables[:sections][params[:name]] = params[:set].inject({}) { |r,i| r[i.first.to_s] = i.last; r }
end
