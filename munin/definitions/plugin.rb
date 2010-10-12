define :munin_plugin, :action => :create, :plugin => nil, :source => nil, :config => nil do
  if tagged?("munin-node")
    params[:plugin] = params[:name] unless params[:plugin]
    plugin_exec = "/usr/libexec/munin/plugins/#{params[:plugin]}"
    plugin_link = "/etc/munin/plugins/#{params[:name]}"
    plugin_conf = "/etc/munin/plugin-conf.d/#{params[:name]}.conf"

    if params[:action] == :create
      if params[:source]
        cookbook_file plugin_exec do
          source params[:source]
          owner "root"
          group "root"
          mode "0755"
        end
      end

      link plugin_link do
        to plugin_exec
        notifies :restart, resources(:service => "munin-node")
      end

      if params[:config]
        template plugin_conf do
          source params[:config]
          owner "root"
          group "root"
          mode "0644"
          notifies :restart, resources(:service => "munin-node")
        end
      end
    else
      if params[:source]
        file plugin_exec do
          action :delete
        end
      end

      file plugin_link do
        action :delete
        notifies :restart, resources(:service => "munin-node")
      end

      file plugin_conf do
        action :delete
        notifies :restart, resources(:service => "munin-node")
      end
    end
  end
end
