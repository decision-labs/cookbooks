module ChefUtils
  module RVM
    include ChefUtils::Account

    def infer_vars(user, version = nil)
      user = getpwnam(user)
      path = user[:name] == "root" ? "/usr/local/rvm" : "#{user[:dir]}/.rvm"
      rvmrc = user[:name] == "root" ? "/etc/rvmrc" : "#{user[:dir]}/.rvmrc"

      return {
        :user => user[:name],
        :group => user[:group][:name],
        :homedir => user[:dir],
        :path => path,
        :rvmrc => rvmrc,
        :version => version,
      }
    end
  end
end

require 'chef/provider/script'
require 'chef/resource/script'
require 'shell'

class Chef
  class Resource
    class RvmExecute < Chef::Resource::Script
      def initialize(name, run_context=nil)
        super
        @resource_name = :rvm_execute
        @interpreter = "bash"
      end
    end
  end

  class Provider
    class RvmScript < Chef::Provider::Script
      include ChefUtils::RVM

      def action_run
        rvm = infer_vars(@new_resource.user)
        script_file.puts("export HOME=#{rvm[:homedir]}\nsource #{rvm[:path]}/scripts/rvm\n")
        super
      end
    end
  end
end

Chef::Platform.set :resource => :rvm_execute, :provider => Chef::Provider::RvmScript
