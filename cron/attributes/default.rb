default[:contacts][:cron] = "root@#{node[:fqdn]}"

set_unless[:cron][:hourly][:minute] = rand(60)

set_unless[:cron][:daily][:minute] = rand(30)
set_unless[:cron][:daily][:hour] = 3

set_unless[:cron][:weekly][:minute] = 15 + rand(30)
set_unless[:cron][:weekly][:hour] = 4
set_unless[:cron][:weekly][:wday] = 6

set_unless[:cron][:monthly][:minute] = 30 + rand(30)
set_unless[:cron][:monthly][:hour] = 5
set_unless[:cron][:monthly][:day] = 1
