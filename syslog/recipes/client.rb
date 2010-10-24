include_recipe "syslog"
include_recipe "syslog::tlsbase"

unless tagged?("syslog-server")
  server_nodes = search(:node, "tags:syslog-server")

  syslog_config "00-remote" do
    template "remote.conf"
    variables :server_nodes => server_nodes
  end
end
