include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)

  current = "#{rvm[:homedir]}/current"
  logfile = "#{current}/log/#{new_resource.environment}.log"
  pidfile = "#{current}/tmp/pids/passenger.pid"

  # XXX: this is not idempotent
  rvm_execute "install passenger" do
    user rvm[:user]
    code <<-EOS
gem query -i -n ^passenger$ -v #{new_resource.version} &>/dev/null || \
gem install passenger -v #{new_resource.version}
EOS
  end

  directory "#{rvm[:homedir]}/bin" do
    owner rvm[:user]
    group rvm[:group]
    mode "0755"
  end

  rvm_wrapper "#{rvm[:homedir]}/bin/passenger" do
    user rvm[:user]
    code <<-EOS
export RAILS_ENV=#{new_resource.environment}
rvm rvmrc untrust #{current}/
cd #{current}

case $@ in
  start)
    passenger start --pid-file #{pidfile} -p #{new_resource.port} --log-file #{logfile} -d #{new_resource.args} -e $RAILS_ENV #{current}
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

  file "/etc/logrotate.d/rvm_passenger-#{rvm[:user]}" do
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

  syslog_config "90-rvm_passenger-#{rvm[:user]}" do
    template "passenger.syslog.conf"
    cookbook "rvm"
    variables :user => rvm[:user],
              :logfile => logfile
  end
end

action :delete do
  rvm = infer_vars(new_resource.user)
end
