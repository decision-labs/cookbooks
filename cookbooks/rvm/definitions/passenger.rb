define :rvm_passenger,
  :version => "3.0.2",
  :environment => "production",
  :port => "3000",
  :args => "" do
  user = params[:name]
  group = Etc.getgrgid(Etc.getpwnam(user)[:gid])[:name]
  homedir = Shell.new.expand_path("~#{user}")

  current = "#{homedir}/current"
  logfile = "#{current}/log/#{params[:environment]}.log"
  pidfile = "#{current}/tmp/pids/passenger.pid"

  # XXX: this is not idempotent
  rvm_execute "install passenger" do
    user user
    code <<-EOS
gem query -i -n ^passenger$ -v #{params[:version]} &>/dev/null || \
gem install passenger -v #{params[:version]}
EOS
  end

  directory "#{homedir}/bin" do
    owner user
    group group
    mode "0755"
  end

  rvm_wrapper "#{homedir}/bin/passenger" do
    user user
    code <<-EOS
export RAILS_ENV=#{params[:environment]}
rvm rvmrc untrust #{current}/
cd #{current}

case $@ in
  start)
    passenger start --pid-file #{pidfile} -p #{params[:port]} --log-file #{logfile} -d #{params[:args]} -e $RAILS_ENV #{current}
  ;;
  stop)
    passenger stop --pid-file #{pidfile}
  ;;
  restart)
    $0 start && $0 stop
  ;;
  *)
  ;;
esac
EOS
  end

  file "/etc/logrotate.d/rvm_passenger-#{user}" do
    content <<-EOS
#{current}/log/*.log {
 missingok
 rotate 100
 size 10M
 copytruncate
}
EOS
    owner "root"
    group "root"
    mode "0644"
  end
end
