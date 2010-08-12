define :nginx_redirect, :from_to => {}, :opts => {} do
  from_host, to_host = params[:from_to].to_a.first
  opts = { :type => :permanent, :ports => [80,443] }.merge(params[:opts] || {})

  file_content = opts[:ports].collect do |port|
    ssl = (port == 443 ? "s" : "")
    <<-EOF
server {
    listen #{ port };
    server_name .#{ from_host };
    rewrite ^/(.*) http#{ ssl }://#{ to_host } #{ opts[:type] };
}
    EOF
  end.join("\n")
  
  file("/etc/nginx/servers/redirect_%s-%s.conf" % [from_host,to_host]) do
    owner "root"
    group "root"
    mode "644"
    content file_content
  end
end
