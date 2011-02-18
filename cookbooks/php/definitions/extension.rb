define :php_extension, :template => nil, :sapis => [], :active => true do
  if params[:sapis].empty?
    params[:sapis] = [node[:php][:sapi]]
  end

  if params[:sapis].include?("apache2")
    service_name = "apache2"
  elsif params[:sapis].include?("fpm")
    service_name = "php-fpm"
  end

  ruby_block "php-extension-dir" do
    block do
      node.set[:php][:extension_dir] = %x(/usr/lib/php#{PHP.slot}/bin/php-config --extension-dir).strip
    end
  end

  for sapi in params[:sapis]
    template "/etc/php/#{sapi}-php#{PHP.slot}/ext/#{params[:name]}.ini" do
      source params[:template]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[#{service_name}]"
    end

    if params[:active]
      link "/etc/php/#{sapi}-php#{PHP.slot}/ext-active/#{params[:name]}.ini" do
        to "/etc/php/#{sapi}-php#{PHP.slot}/ext/#{params[:name]}.ini"
        notifies :restart, "service[#{service_name}]"
      end
    else
      file "/etc/php/#{sapi}-php#{PHP.slot}/ext-active/#{params[:name]}.ini" do
        action :delete
        notifies :restart, "service[#{service_name}]"
      end
    end
  end
end
