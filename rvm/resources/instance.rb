def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :version, :kind_of => String, :default => "1.0.5"
