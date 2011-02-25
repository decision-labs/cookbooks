def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :install
end

actions :install, :uninstall

attribute :user, :kind_of => String
attribute :use, :kind_of => String, :default => nil
attribute :version, :kind_of => String, :default => nil
