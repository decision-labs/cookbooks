default[:ssh][:additional_host_keys] = []

default[:ssh][:server][:password_auth] = "no"
default[:ssh][:server][:challange_response_auth] = "no"
default[:ssh][:server][:root_login] = "no"
default[:ssh][:server][:x11_forwarding] = "no"
default[:ssh][:server][:use_lpk] = "no"
default[:ssh][:server][:allow_local_root] = "no"
default[:ssh][:server][:max_auth_tries] = 6
default[:ssh][:server][:matches] = {}
