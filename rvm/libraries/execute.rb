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

      def code(arg=nil)
        if arg
          rvm_user = user ? user : Etc.getpwuid(Process.euid).name
          homedir = Shell.new.expand_path("~#{rvm_user}")
          rvm_path = rvm_user == "root" ? "/usr/local/rvm" : "#{homedir}/.rvm"
          arg = "export HOME=#{homedir}\nsource #{rvm_path}/scripts/rvm\n#{arg}"
        end
        super(arg)
      end
    end
  end
end

Chef::Platform.set :resource => :rvm_execute, :provider => Chef::Provider::Script
