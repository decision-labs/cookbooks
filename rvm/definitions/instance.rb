require "shell"

#
# name is the user name for whom we're going to install RVM
#
define :rvm_instance,
  :action => :create,
  :version => '1.0.5',
  :rubies => [] do

  rvm_user  = params[:name]
  rvm_group = Etc.getgrgid(Etc.getpwnam(rvm_user)[:gid])[:name]
  homedir   = Shell.new.expand_path("~#{rvm_user}")
  rvm_path  = rvm_user == "root" ? "/usr/local/rvm" : "#{homedir}/.rvm"
  rvm       = "#{rvm_path}/bin/rvm"

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

    rvm_execute "install library dependencies" do
      code <<-EOS
      for i in zlib ncurses readline openssl iconv libxml2; do
        rvm package install $i
      done
      EOS

      environment "HOME" => homedir
      creates "#{rvm_path}/usr/lib/libxml2.so"
      user rvm_user
      group rvm_group
    end

    params[:rubies].each do |ruby_version|
      rvm_execute "installing ruby interpreter: #{ruby_version}" do
        code <<-EOS
        full_version=$(rvm strings #{ruby_version})
        rvm install ${full_version} -C --with-readline-dir=${rvm_path}/usr,--with-iconv-dir=${rvm_path}/usr,--with-zlib-dir=${rvm_path}/usr,--with-openssl-dir=${rvm_path}/usr
        touch ${rvm_path}/rubies/${full_version}/lib/ruby/site_ruby/auto_gem.rb
        EOS

        environment "HOME" => homedir
        creates "#{rvm_path}/rubies/#{ruby_version}"
        user rvm_user
        group rvm_group
      end
    end

  when :delete
    directory rvm_path do
      action :delete
      recursive true
    end
  end

end
