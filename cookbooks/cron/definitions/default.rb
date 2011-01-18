define :cron_hourly, :command => nil, :action => :create do
  file "/etc/cron.hourly/#{params[:name]}" do
    content "#!/bin/sh\n#{params[:command]}\n"
    mode "0755"
    action params[:action]
  end
end

define :cron_daily, :command => nil, :action => :create do
  file "/etc/cron.daily/#{params[:name]}" do
    content "#!/bin/sh\n#{params[:command]}\n"
    mode "0755"
    action params[:action]
  end
end

define :cron_weekly, :command => nil, :action => :create do
  file "/etc/cron.weekly/#{params[:name]}" do
    content "#!/bin/sh\n#{params[:command]}\n"
    mode "0755"
    action params[:action]
  end
end

define :cron_monthly, :command => nil, :action => :create do
  file "/etc/cron.monthly/#{params[:name]}" do
    content "#!/bin/sh\n#{params[:command]}\n"
    mode "0755"
    action params[:action]
  end
end
