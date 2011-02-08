default[:mongodb][:bind_ip] = "127.0.0.1"
default[:mongodb][:port] = "27017"
default[:mongodb][:dbpath] = "/var/lib/mongodb"
default[:mongodb][:replication][:set] = nil
default[:mongodb][:shardsvr] = false

default[:mongoc][:bind_ip] = "127.0.0.1"
default[:mongoc][:port] = "27117"
default[:mongoc][:dbpath] = "/var/lib/mongoc"

default[:mongos][:bind_ip] = "127.0.0.1"
default[:mongos][:port] = "27217"
default[:mongos][:configdb] = []
