default[:contacts][:cron] = "root@#{node[:fqdn]}"

default[:cron][:hourly][:minute] = rand(60)

default[:cron][:daily][:minute] = rand(30)
default[:cron][:daily][:hour] = 3

default[:cron][:weekly][:minute] = 15 + rand(30)
default[:cron][:weekly][:hour] = 4
default[:cron][:weekly][:wday] = 6

default[:cron][:monthly][:minute] = 30 + rand(30)
default[:cron][:monthly][:hour] = 5
default[:cron][:monthly][:day] = 1
