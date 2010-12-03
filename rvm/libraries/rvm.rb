module ChefUtils
  module RVM
    def infer_vars(user, version = nil)
      group = Etc.getgrgid(Etc.getpwnam(user)[:gid])[:name]
      homedir = Shell.new.expand_path("~#{user}")
      path = user == "root" ? "/usr/local/rvm" : "#{homedir}/.rvm"
      rvmrc = user == "root" ? "/etc/rvmrc" : "#{homedir}/.rvmrc"

      return {
        :user => user,
        :group => group,
        :homedir => homedir,
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
