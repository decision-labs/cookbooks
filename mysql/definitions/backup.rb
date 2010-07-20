define :mysql_backup,
  :dbnames => "all",
  :backupdir => "/var/backup/mysql/",
  :dbexclude => "",
  :tabignore => "",
  :opts => "--single-transaction" do

  name = params[:name]

  directory params[:backupdir] do
    owner "root"
    group "root"
    mode "0700"
    recursive true
  end

  template "/usr/local/sbin/mysqlbackup-#{name}" do
    source "mysqlbackup.erb"
    owner "root"
    group "root"
    mode "0700"
    cookbook "mysql"
    variables :params => params
  end

  cron_daily "mysqlbackup-#{name}" do
    command "/usr/bin/lockrun --lockfile=/var/lock/mysqlbackup-#{name}.cron -- /usr/local/sbin/mysqlbackup-#{name}"
  end
end
