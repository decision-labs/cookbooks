default[:contacts][:cron] = "root@#{node[:fqdn]}"

# seed with host specific data to make it idempotent
require 'ipaddr'
srand(IPAddr.new(node[:ipaddress]).to_i)

set[:cron][:hourly][:minute] = rand(60)

set[:cron][:daily][:minute] = rand(30)
set[:cron][:daily][:hour] = 3

set[:cron][:weekly][:minute] = 15 + rand(30)
set[:cron][:weekly][:hour] = 4
set[:cron][:weekly][:wday] = 6

set[:cron][:monthly][:minute] = 30 + rand(30)
set[:cron][:monthly][:hour] = 5
set[:cron][:monthly][:day] = 1
