include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)

  version = new_resource.version
  environment = new_resource.environment

  config = {
    :worker_processes => 4,
    :timeout => 30,
    :port => 3000,
    :backlog => 64,
    :homedir => rvm[:homedir],
  }.merge(new_resource.config)

  current = "#{rvm[:homedir]}/current"
  logfile = "#{current}/log/#{environment}.log"

  directory "#{rvm[:homedir]}/bin" do
    owner rvm[:user]
    group rvm[:group]
    mode "0755"
  end

  template "#{rvm[:homedir]}/shared/config/unicorn.rb" do
    source "unicorn.rb"
    cookbook "capistrano"
    owner rvm[:user]
    group rvm[:group]
    mode "0755"
    variables :params => config
  end

  rvm_wrapper "#{rvm[:homedir]}/bin/unicorn" do
    user rvm[:user]
    code <<-EOS
export RAILS_ENV=#{environment}

PIDFILE=#{rvm[:homedir]}/shared/pids/unicorn.pid
CONFIG=#{rvm[:homedir]}/shared/config/unicorn.rb
CMD="bundle exec unicorn_rails -c $CONFIG -E $RAILS_ENV -D"

cd #{current}

sig () {
  test -s "$PIDFILE" && kill -$1 $(<$PIDFILE)
}

case $1 in
start)
  sig 0 && echo >&2 "Already running" && exit 0
  $CMD
  ;;
stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;
graceful_stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;
reload)
  sig HUP && echo reloaded OK && exit 0
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  $CMD
  ;;
upgrade)
  sig USR2 && exit 0
  echo >&2 "Couldn't upgrade, starting '$CMD' instead"
  $CMD
  ;;
rotate)
  sig USR1 && echo rotated logs OK && exit 0
  echo >&2 "Couldn't rotate logs" && exit 1
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|graceful_stop|reload|upgrade|rotate>"
  exit 1
  ;;
esac
EOS
  end

  syslog_config "90-capistrano_unicorn-#{rvm[:user]}" do
    template "unicorn.syslog.conf"
    cookbook "capistrano"
    variables :user => rvm[:user],
              :logfile => logfile
  end
end

action :delete do
  rvm = infer_vars(new_resource.user)
end
