define :php_extension, :template => nil, :sapis => ['fpm'], :active => true do
  for sapi in params[:sapis]
    template "/etc/php/#{sapi}-php5/ext/#{params[:name]}.ini" do
      source params[:template]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => "php-fpm")
    end

    if params[:active]
      link "/etc/php/#{sapi}-php5/ext-active/#{params[:name]}.ini" do
        to "/etc/php/#{sapi}-php5/ext/#{params[:name]}.ini"
        notifies :restart, resources(:service => "php-fpm")
      end
    else
      file "/etc/php/#{sapi}-php5/ext-active/#{params[:name]}.ini" do
        action :delete
        notifies :restart, resources(:service => "php-fpm")
      end
    end
  end
end
