def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :package, :kind_of => String, :name_attribute => true
attribute :keywords, :kind_of => [ String, Array ]
