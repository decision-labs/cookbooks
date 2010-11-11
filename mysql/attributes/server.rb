# paths
default[:mysql][:server][:sharedstatedir] = "/usr/share/mysql"
default[:mysql][:server][:sysconfdir] = "/etc/mysql"
default[:mysql][:server][:libdir] = "/usr/lib/mysql"
default[:mysql][:server][:localstatedir] = "/var/lib/mysql"
default[:mysql][:server][:logdir] = "/var/log/mysql"
default[:mysql][:server][:rundir] = "/var/run/mysqld"
default[:mysql][:server][:includedir] = "/usr/include/mysql"
default[:mysql][:server][:datadir] = "/var/lib/mysql"
default[:mysql][:server][:tmpdir] = "/var/tmp"

# general security & performance tuning
default[:mysql][:server][:skip_networking] = false
default[:mysql][:server][:bind_address] = "127.0.0.1"
default[:mysql][:server][:skip_innodb] = false

# replication and binary log
default[:mysql][:server][:server_id] = 1
default[:mysql][:server][:log_bin] = false
default[:mysql][:server][:sync_binlog] = "1"
default[:mysql][:server][:relay_log] = false
default[:mysql][:server][:expire_logs_days] = 14
default[:mysql][:server][:log_slave_updates] = false
default[:mysql][:server][:replicate_do_db] = false

# slow query log
default[:mysql][:server][:long_query_time] = "2"

# client connection optimization
default[:mysql][:server][:max_connections] = "128"
default[:mysql][:server][:max_allowed_packet] = "16M"
default[:mysql][:server][:net_buffer_length] = "8K"
default[:mysql][:server][:wait_timeout] = "28800"
default[:mysql][:server][:connect_timeout] = "10"

# key buffer optimization
default[:mysql][:server][:key_buffer_size] = "64M"

# query cache optimization
default[:mysql][:server][:query_cache_size] = "128M"
default[:mysql][:server][:query_cache_type] = 1
default[:mysql][:server][:query_cache_limit] = "4M"

# sort optimization
default[:mysql][:server][:sort_buffer_size] = "4M"
default[:mysql][:server][:read_buffer_size] = "1M"
default[:mysql][:server][:read_rnd_buffer_size] = "512K"
default[:mysql][:server][:myisam_sort_buffer_size] = "64M"

# join optimization
default[:mysql][:server][:join_buffer_size] = "2M"

# open files & table cache
default[:mysql][:server][:open_files_limit] = "4096"
default[:mysql][:server][:table_cache] = "1024"

# temporary tables
default[:mysql][:server][:tmp_table_size] = "64M"
default[:mysql][:server][:max_heap_table_size] = "64M"

# thread cache
default[:mysql][:server][:thread_cache_size] = "16"

# innodb
default[:mysql][:server][:innodb_file_per_table] = true
default[:mysql][:server][:innodb_data_home_dir] = "/var/lib/mysql"
default[:mysql][:server][:innodb_buffer_pool_size] = "512M"
default[:mysql][:server][:innodb_log_file_size] = "256M"
default[:mysql][:server][:innodb_flush_log_at_trx_commit] = "1"

# backup
default[:mysql][:backupdir] = "/var/backup/mysql"
default[:mysql][:backups] = {}
