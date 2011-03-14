include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)

  current = "#{rvm[:homedir]}/current"
  logfile = "#{current}/log/#{new_resource.environment}.log"
  pidfile = "#{current}/tmp/pids/passenger.pid"

  rvm_gem "passenger" do
    user rvm[:user]
    version new_resource.version
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
