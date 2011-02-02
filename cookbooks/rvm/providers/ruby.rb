include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)

  ruby_config = {
    :version => "ruby-1.9.2-p136",
    :libpath => "lib/ruby/site_ruby",
  }

  if new_resource.ruby_config
    ruby_config = new_resource.ruby_config
  end

  rvm_execute "installing ruby interpreter: #{ruby_config[:version]}" do
    code <<-EOS
    rvm install #{ruby_config[:version]}
    mkdir -p ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}
    touch ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb
    rvm use #{ruby_config[:version]}
    gem install bundler
    EOS

    creates "#{rvm[:path]}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb"
    user rvm[:user]
  end

  if new_resource.default
    rvm_execute "setting default interpreter" do
      code "rvm --default #{ruby_config[:version]}"

      user rvm[:user]
      not_if do
        begin
          File.readlink("#{rvm[:path]}/rubies/default") == "#{rvm[:path]}/rubies/#{ruby_config[:version]}"
        rescue
          false
        end
      end
    end
  end

  bash "creating fake entry in /var/db/pkg" do
    code "fake-vardb rvm/#{rvm[:user]} #{rvm[:path]}/rubies #{rvm[:path]}/gems"
    not_if do
      begin
        FileUtils.uptodate?("/var/db/pkg/rvm/#{rvm[:user]}-0/CONTENTS", ["#{rvm[:path]}/.last_install_action"])
      rescue
        false
      end
    end
  end
end

action :delete do
  rvm = infer_vars(new_resource.user)
end
