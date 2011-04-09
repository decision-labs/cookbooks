namespace :node do

  desc "Create a new node with SSL certificates and chef client key"
  task :create => [ :pull ]
  task :create, :fqdn do |t, args|
    fqdn = args.fqdn

    # create SSL cert
    ENV['BATCH'] = "1"
    Rake::Task['ssl:do_cert'].invoke(fqdn)
    Rake::Task['load:cookbook'].invoke('openssl')

    # create new node
    nf = File.join(TOPDIR, "nodes", "#{fqdn}.rb")

    unless File.exists?(nf)
      File.open(nf, "w") do |fd|
        fd.puts <<EOH
run_list(%w(
  role[base]
))
EOH
      end
    end

    Rake::Task['load:node'].invoke(fqdn)

    # create new client cert
    sh("knife client -n create #{fqdn}")
  end

  task :delete, :fqdn do |t, args|
    fqdn = args.fqdn

    # revoke SSL cert
    ENV['BATCH'] = "1"
    Rake::Task['ssl:revoke'].invoke(fqdn)
    Rake::Task['load:cookbook'].invoke('openssl')

    # remove new node
    File.unlink(File.join(TOPDIR, "nodes", "#{fqdn}.rb"))
    sh("knife node delete -y #{fqdn}")

    # remove client cert
    sh("knife client delete -y #{fqdn}")
  end

end
