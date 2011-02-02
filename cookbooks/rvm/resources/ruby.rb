def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :default, :kind_of => [TrueClass, FalseClass], :default => true
attribute :ruby_config, :kind_of => Hash, :default => nil
