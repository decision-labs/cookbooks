require "shell"

#
# name is the user name for whom we're going to install RVM
#
define :rvm_instance,
  :action => :create,
  :version => '1.0.5' do

  rvm_user  = params[:name]
  rvm_group = Etc.getgrgid(Etc.getpwnam(rvm_user)[:gid])[:name]
  homedir   = Shell.new.expand_path("~#{rvm_user}")
  rvm_path  = rvm_user == "root" ? "/usr/local/rvm" : "#{homedir}/.rvm"

  node.set[:rvm][:instance][rvm_user] = {
    :path => rvm_path,
    :user => rvm_user,
    :group => rvm_group,
  }

  case params[:action]
  when :create

    rvmrc = rvm_user == "root" ? "/etc/rvmrc" : "#{homedir}/.rvmrc"

    file rvmrc do
      content "rvm_selfcontained=1\nrvm_prefix=#{File.dirname(rvm_path)}\nrvm_path=#{rvm_path}\n"
      owner rvm_user
      group rvm_group
      mode "0644"
    end

    bash "install rvm-#{params[:version]}" do
      code <<-EOS
      export rvm_path="#{rvm_path}"
      stable_version=#{params[:version]}

      mkdir -p ${rvm_path}/src
      builtin cd ${rvm_path}/src

      curl -L "http://rvm.beginrescueend.com/releases/rvm-${stable_version}.tar.gz" -o "rvm-${stable_version}.tar.gz"
      tar zxf "rvm-${stable_version}.tar.gz"

      builtin cd "rvm-${stable_version}"
      bash ./scripts/install
      EOS

      environment "HOME" => homedir
      creates "#{rvm_path}/src/rvm-#{params[:version]}"
      user rvm_user
      group rvm_group
    end

    file "#{rvm_path}/gemsets/global.gems" do
      content "bundler\n"
      owner rvm_user
      group rvm_group
      mode "0644"
    end

  when :delete
    directory rvm_path do
      action :delete
      recursive true
    end
  end

end
