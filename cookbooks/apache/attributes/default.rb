default[:apache][:apr_util][:use] = Array.new
default[:apache][:mpm] = "prefork"
default[:apache][:default_redirect] = nil
default[:apache][:ssl][:enabled] = false
default[:apache][:error_log] = "syslog:daemon"
