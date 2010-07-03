def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :package, :kind_of => String, :name_attribute => true
attribute :use, :kind_of => [ String, Array ]
