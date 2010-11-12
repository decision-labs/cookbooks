define :php_extension, :template => nil, :sapis => [], :active => true do
  if params[:sapis].empty?
    params[:sapis] = [node[:php][:sapi]]
  end

  if params[:sapis].include?("apache2")
    service_name = "apache2"
  elsif params[:sapis].include?("fpm")
    service_name = "php-fpm"
  end

  for sapi in params[:sapis]
    template "/etc/php/#{sapi}-php5/ext/#{params[:name]}.ini" do
      source params[:template]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => service_name)
    end

    if params[:active]
      link "/etc/php/#{sapi}-php5/ext-active/#{params[:name]}.ini" do
        to "/etc/php/#{sapi}-php5/ext/#{params[:name]}.ini"
        notifies :restart, resources(:service => service_name)
      end
    else
      file "/etc/php/#{sapi}-php5/ext-active/#{params[:name]}.ini" do
        action :delete
        notifies :restart, resources(:service => service_name)
      end
    end
  end
end
