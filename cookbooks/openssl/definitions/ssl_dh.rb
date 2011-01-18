define :ssl_dh, :owner => "root", :group => "root", :mode => "0444" do
  include_recipe "openssl"

  execute "create DH file #{params[:name]}" do
    command "openssl dhparam -out #{params[:name]} 2048"
    creates params[:name]
  end
end
