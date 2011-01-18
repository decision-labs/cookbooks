def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :code, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => true
attribute :mode, :kind_of => String, :default => "0755"
