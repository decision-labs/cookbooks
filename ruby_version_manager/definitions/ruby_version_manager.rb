#
# name is the user name for whom we're going to install RVM
#
define :use_ruby_version_manager, :action => :create, :versions => ["ruby-1.9.2-head","ree-1.8.7-head"] do
  homedir   = "/home/#{params[:name]}"
  rvmdir    = "#{homedir}/.rvm"
  rvmsrcdir = "#{rvmdir}/src"

  if params[:action] == :create
    execute "clone ruby version manager" do
      command "git clone --depth 1 git://github.com/wayneeseguin/rvm.git #{rvmsrcdir}/rvm"
      creates "#{rvmsrcdir}/rvm"
      user  params[:name]
      group "users"
      cwd   homedir
    end

    execute "install ruby version manager" do
      command "cd #{rvmsrcdir}/rvm && ./install"
      creates "#{rvmdir}/scripts"
      environment({ "HOME" => homedir })
      user  params[:name]
      group "users"
      cwd   homedir
    end
    
    params[:versions].each do |ruby_version|
      logfile="/tmp/rvm-install-#{ruby_version}.#{(rand*1000000).to_i}.log"
      Chef::Log.debug("[RVM] Will install #{ruby_version} to #{rvmdir}")
      Chef::Log.debug("[RVM] Logfile: tail -f #{logfile}")
      execute "install specific version of ruby - #{ruby_version}" do
        ## .rvm/scripts/rvm has exit value 1 ... even if things went well
        command "source #{rvmdir}/scripts/rvm || echo && rvm install #{ruby_version} >#{logfile} 2>&1"
        creates "#{rvmdir}/rubies/#{ruby_version}"
        environment({ "HOME" => homedir })
        user  params[:name]
        group "users"
        cwd   homedir
      end
    end

    ## TODO add extra line from .bashrc that does the including
    ## echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> .bashr
  else
    # assume delete
    ## TODO remove extra line from .bashrc that does the including
    directory rvmdir do
      action :delete
      recursive true
    end
  end
end

##
## This is similar to gem_package except that it installs the required gem for each
## of the rvm rubies that have been installed (or just for those specified by :for_versions).
## The only addition to the gem_package is the requirement that a User is provided. Needed
## because RVM is installed on a per-user basis.
##
define :rvm_gem_package, :action => :install, :for_versions => nil, :user => nil do
  ## for_versions ==> nil ==> for all installed versions of RVM.
  gem_v, gem_s, rvm_user, gem_n, action = [:version, :source, :user, :name, :action].map{ |a| params[a] }
  homedir = "/home/#{rvm_user}"
  gem_v   = gem_v.nil? ? nil : "-v=#{gem_v}"
  gem_s   = gem_s.nil? ? nil : "--source #{gem_s}"
  Chef::Log.debug("[RVM] [GEM] Installing #{gem_n} (#{gem_v || '-'}, #{gem_s || '-'})")

  ## common stuff that has to be done all the time
  c = ["source #{homedir}/.rvm/scripts/rvm || echo", 'rvm use %s >/dev/null']

  ## basic check whether gem is already installed... TODO needs to be improved --> gems
  ## that have a different gem name when installed or different source specification.
  grep_for_version = gem_v.nil? ? "" : "| grep '%s'" % gem_v
  gem_action       = action == :install ? "install" : "uninstall"
  not_installed_check = (c + ['[[ $(gem list %s --local %s | wc -l) -eq 0 ]]' % 
                              [gem_n,grep_for_version]]).join(" && ")
  install_str         = (c + ["gem %s %s %s %s" % [gem_action,gem_n,gem_v,gem_s]]).join(" && ")

  (if params[:for_versions].nil?
     ::Dir.glob("#{homedir}/.rvm/rubies/*").map { |a| ::File.basename(a) }
   else
     params[:for_versions]
   end).each do |ruby_version|
    Chef::Log.debug("[RVM] [GEM] Will install #{gem_n} for #{ruby_version}")
    execute "installing #{gem_n} for #{ruby_version}" do
      command install_str % ruby_version
      environment({ "HOME" => homedir, "RUBYOPT" => "" })
      user    rvm_user
      group   "users"
      cwd     homedir
      only_if not_installed_check % ruby_version
    end
  end
end
