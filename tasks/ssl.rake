require 'tempfile'
require 'chef'

namespace :ssl do
  desc "Initialize the OpenSSL CA"
  task :init => [ :pull ]
  task :init do
    FileUtils.mkdir_p(SSL_CERT_DIR)
    FileUtils.mkdir_p(File.join(SSL_CA_DIR, "crl"))
    FileUtils.mkdir_p(File.join(SSL_CA_DIR, "newcerts"))
    FileUtils.touch(File.join(SSL_CA_DIR, "index"))

    unless File.exists?(File.join(SSL_CA_DIR, "serial"))
      File.open(File.join(SSL_CA_DIR, "serial"), "w") do |f|
        f.puts("01")
      end
    end

    unless File.exists?(File.join(SSL_CA_DIR, "crlnumber"))
      File.open(File.join(SSL_CA_DIR, "crlnumber"), "w") do |f|
        f.puts("01")
      end
    end

    unless File.exists?(File.join(SSL_CERT_DIR, "ca.crt"))
      subject = "/C=#{SSL_COUNTRY_NAME}/ST=#{SSL_STATE_NAME}/L=#{SSL_LOCALITY_NAME}/O=#{COMPANY_NAME}/OU=#{SSL_ORGANIZATIONAL_UNIT_NAME}/CN=Certificate Signing Authority/emailAddress=#{SSL_EMAIL_ADDRESS}"
      sh("openssl req -config #{SSL_CONFIG_FILE} -new -nodes -x509 -days 3650 -subj '#{subject}' -newkey rsa:4096 -out #{SSL_CERT_DIR}/ca.crt -keyout #{SSL_CA_DIR}/ca.key")
      sh("openssl ca -config #{SSL_CONFIG_FILE} -gencrl -out #{SSL_CERT_DIR}/ca.crl")
    end
  end

  task :do_cert => [ :init, :pull ]
  task :do_cert, :cn do |t, args|
    cn = args.cn
    keyfile = cn.gsub("*", "wildcard")

    FileUtils.mkdir_p(SSL_CERT_DIR)

    unless File.exist?(File.join(SSL_CERT_DIR, "#{keyfile}.key"))
      puts("** Creating SSL Certificate Request for #{cn}")
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
commonName_default              = #{cn}

emailAddress                    = Email Address
emailAddress_max                = 64
emailAddress_default            = #{SSL_EMAIL_ADDRESS}
EOH
      tf.puts(ssl_config)
      tf.close
      if ENV['BATCH'] == "1"
        sh("openssl req -new -batch -nodes -config '#{tf.path}' -keyout #{SSL_CERT_DIR}/#{keyfile}.key -out #{SSL_CERT_DIR}/#{keyfile}.csr -newkey rsa:2048")
      else
        sh("openssl req -new -nodes -config '#{tf.path}' -keyout #{SSL_CERT_DIR}/#{keyfile}.key -out #{SSL_CERT_DIR}/#{keyfile}.csr -newkey rsa:2048")
      end
      sh("chmod 644 #{SSL_CERT_DIR}/#{keyfile}.key #{SSL_CERT_DIR}/#{keyfile}.csr")
    else
      puts("** SSL Certificate Request for #{cn} already exists, skipping.")
    end

    unless File.exist?(File.join(SSL_CERT_DIR, "#{keyfile}.crt"))
      puts("** Signing SSL Certificate Request for #{cn}")
      sh("openssl ca -config #{SSL_CONFIG_FILE} -batch -in #{SSL_CERT_DIR}/#{keyfile}.csr -out #{SSL_CERT_DIR}/#{keyfile}.crt")
      sh("chmod 644 #{SSL_CERT_DIR}/#{keyfile}.crt")
    else
      puts("** SSL Certificate for #{cn} already exists, skipping.")
    end
  end

  desc "Create a new SSL certificate"
  task :cert, :cn do |t, args|
    Rake::Task["ssl:do_cert"].invoke(args.cn)
  end

  desc "Create missing SSL certificates"
  task :create_missing_certs do
    Chef::Node.list.keys.each do |fqdn|
      Rake::Task["ssl:do_cert"].invoke(fqdn)
    end
  end

  desc "Revoke an existing SSL certificate"
  task :revoke => [ :pull ]
  task :revoke, :cn do |t, args|
    keyfile = args.cn.gsub("*", "wildcard")
    sh("openssl ca -config #{SSL_CONFIG_FILE} -revoke #{SSL_CERT_DIR}/#{keyfile}.crt")
    sh("openssl ca -config #{SSL_CONFIG_FILE} -gencrl -out #{SSL_CERT_DIR}/ca.crl")
    sh("rm #{SSL_CERT_DIR}/#{keyfile}.{csr,crt,key}")
  end
end
