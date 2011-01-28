define :rvm_ruby,
  :default => true do

  user = params[:name]
  homedir = Shell.new.expand_path("~#{user}")
  rvm_path = "#{homedir}/.rvm"

  ruby_config = {
    :version => "ruby-1.9.2-p136",
    :libpath => "lib/ruby/site_ruby",
  }

  if params[:ruby_config]
    ruby_config = params[:ruby_config]
  end

  rvm_execute "installing ruby interpreter: #{ruby_config[:version]}" do
    code <<-EOS
    rvm install #{ruby_config[:version]}
    mkdir -p ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}
    touch ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb
    rvm use #{ruby_config[:version]}
    gem install bundler
    EOS

    creates "#{rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb"
    user user
  end

  if params[:default]
    rvm_execute "setting default interpreter" do
      code "rvm --default #{ruby_config[:version]}"

      user user
      not_if do
        begin
          File.readlink("#{rvm_path}/rubies/default") == "#{rvm_path}/rubies/#{ruby_config[:version]}"
        rescue
          false
        end
      end
    end
  end

  bash "creating fake entry in /var/db/pkg" do
    code "fake-vardb rvm/#{user} #{rvm_path}/rubies #{rvm_path}/gems"
    not_if do
      begin
        FileUtils.uptodate?("/var/db/pkg/rvm/#{user}-0/CONTENTS", ["#{rvm_path}/.last_install_action"])
      rescue
        false
      end
    end
  end
end
