def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :version, :kind_of => String, :default => "3.0.2"
attribute :environment, :kind_of => String, :default => "production"
attribute :port, :kind_of => String, :default => "3000"
attribute :args, :kind_of => String, :default => ""
