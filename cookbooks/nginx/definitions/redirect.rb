define :nginx_redirect, :from_to => {}, :opts => {} do
  from_host, to_host = params[:from_to].to_a.first
  opts = { :type => :permanent, :ports => [80,443] }.merge(params[:opts] || {})
  ssl_certificate = <<-EOF
    ssl on;
    ssl_certificate      /etc/ssl/nginx/nginx.crt;
    ssl_certificate_key  /etc/ssl/nginx/nginx.key; 
  EOF

  file_content = opts[:ports].collect do |port|
    ssl = (port == 443)
    <<-EOF
    server {
      listen #{ port };
      #{ssl ? ssl_certificate : ''}
      server_name .#{ from_host };
      rewrite ^(.*)$ http#{ ssl ? 's' : ''}://#{ to_host }$1 #{ opts[:type] };
    }
    EOF
  end.join("\n")
  
  file("/etc/nginx/servers/redirect_%s-%s.conf" % [from_host,to_host]) do
    owner "root"
    group "root"
    mode "644"
    notifies :restart, "service[nginx]"
    content file_content
  end
end
