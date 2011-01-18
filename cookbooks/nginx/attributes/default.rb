default[:nginx][:use_flags] = []

default[:nginx][:worker_processes] = "4"
default[:nginx][:worker_connections] = "1024"
default[:nginx][:client_max_body_size] = "10M"
