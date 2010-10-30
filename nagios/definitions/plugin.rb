define :nagios_plugin, :source => nil, :content => nil do
  if tagged?("nagios-client")
    directory "/usr/lib/nagios" do
      owner "root"
      group "root"
      mode "0755"
    end

    directory "/usr/lib/nagios/plugins" do
      owner "root"
      group "nagios"
      mode "0755"
    end

    if params[:source]
      cookbook_file "/usr/lib/nagios/plugins/check_#{params[:name]}" do
        source params[:source]
        owner "root"
        group "nagios"
        mode "0750"
      end
    else
      file "/usr/lib/nagios/plugins/check_#{params[:name]}" do
        content params[:content]
        owner "root"
        group "nagios"
        mode "0750"
      end
    end
  end
end
