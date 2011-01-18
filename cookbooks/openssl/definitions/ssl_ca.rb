define :ssl_ca, :symlink => false, :owner => "root", :group => "root", :mode => "0444" do
  include_recipe "openssl"

  %w(crt crl).each do |t|
    cookbook_file "#{params[:name]}.#{t}" do
      owner params[:owner]
      group params[:group]
      mode params[:mode]
      source "certificates/ca.#{t}"
      cookbook "openssl"
    end
  end

  if params[:symlink]
    execute "#{params[:name]}-ca-symlink" do
      command "ln -s #{File.basename(params[:name])}.crt #{File.dirname(params[:name])}/`openssl x509 -noout -hash -in #{params[:name]}.crt`.0"
      not_if "test -e #{File.dirname(params[:name])}/`openssl x509 -noout -hash -in #{params[:name]}.crt`.0"
    end

    execute "#{params[:name]}-crl-symlink" do
      command "ln -s #{File.basename(params[:name])}.crl #{File.dirname(params[:name])}/`openssl crl -noout -hash -in #{params[:name]}.crl`.r0"
      not_if "test -e #{File.dirname(params[:name])}/`openssl crl -noout -hash -in #{params[:name]}.crl`.r0"
    end
  end
end
