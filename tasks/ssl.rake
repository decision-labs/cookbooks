require 'tempfile'

task :ssl_init do
  FileUtils.mkdir_p(CADIR)
end

desc "Create a new private CA"
task :ssl_ca => [ :ssl_init ] do
  unless File.exist?(File.join(CADIR, "ca.key"))
    puts "** Creating private CA"
    subject = "/C=#{SSL_COUNTRY_NAME}/ST=#{SSL_STATE_NAME}/L=#{SSL_LOCALITY_NAME}/O=#{COMPANY_NAME}/OU=#{SSL_ORGANIZATIONAL_UNIT_NAME}/CN=Certificate Signing Authority/emailAddress=#{SSL_EMAIL_ADDRESS}"
    sh("(cd #{CADIR} && openssl req -new -nodes -x509 -days 3650 -subj '#{subject}' -keyout ca.key -out ca.crt -newkey rsa:4096)")
    sh("(cd #{CADIR} && echo 00 > ca.srl)")
  end
end

desc "Create a new SSL certificate"
task :ssl_cert => [ :ssl_ca ]
task :ssl_cert, :cn do |t, args|
  args.with_defaults(:cn => "localhost")
  keyfile = args.cn.gsub("*", "wildcard")

  unless File.exist?(File.join(CADIR, "#{keyfile}.key"))
    puts "** Creating SSL Certificate Request for #{args.cn}"
    tf = Tempfile.new("#{keyfile}.ssl-conf")
    ssl_config = <<EOH
[ req ]
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = #{SSL_COUNTRY_NAME}
countryName_min                 = 2
countryName_max                 = 2

stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = #{SSL_STATE_NAME}

localityName                    = Locality Name (eg, city)
localityName_default            = #{SSL_LOCALITY_NAME}

0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = #{COMPANY_NAME}

organizationalUnitName          = Organizational Unit Name (eg, section)
organizationalUnitName_default  = #{SSL_ORGANIZATIONAL_UNIT_NAME}

commonName                      = Common Name (eg, YOUR name)
commonName_max                  = 64
commonName_default              = #{args.cn}

emailAddress                    = Email Address
emailAddress_max                = 64
emailAddress_default            = #{SSL_EMAIL_ADDRESS}
EOH
    tf.puts(ssl_config)
    tf.close
    subject = "/C=#{SSL_COUNTRY_NAME}/ST=#{SSL_STATE_NAME}/L=#{SSL_LOCALITY_NAME}/O=#{COMPANY_NAME}/OU=#{SSL_ORGANIZATIONAL_UNIT_NAME}/CN=#{args.cn}/emailAddress=#{SSL_EMAIL_ADDRESS}"
    sh("(cd #{CADIR} && openssl req -new -nodes -config '#{tf.path}' -keyout #{keyfile}.key -out #{keyfile}.csr -newkey rsa:2048)")
    sh("(cd #{CADIR} && chmod 644 #{keyfile}.key #{keyfile}.csr)")
  else
    puts "** SSL Certificate Request for #{args.cn} already exists, skipping."
  end

  unless File.exist?(File.join(CADIR, "#{keyfile}.crt"))
    puts "** Signing SSL Certificate Request for #{args.cn}"
    sh("(cd #{CADIR} && openssl x509 -req -days 365 -in #{keyfile}.csr -CA #{CADIR}/ca.crt -CAkey #{CADIR}/ca.key -out #{keyfile}.crt)")
    sh("(cd #{CADIR} && openssl x509 -noout -fingerprint -text < #{keyfile}.crt > #{keyfile}.info)")
    sh("(cd #{CADIR} && cat #{keyfile}.crt #{keyfile}.key > #{keyfile}.pem)")
    sh("(cd #{CADIR} && chmod 644 #{keyfile}.pem)")
  else
    puts "** SSL Certificate for #{args.cn} already exists, skipping."
  end
end
