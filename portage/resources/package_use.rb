def initialize(name, collection=nil, node=nil)
  super(name, collection, node)
  @action = :create
end

actions :create, :delete

attribute :package, :kind_of => String, :name_attribute => true
attribute :use, :kind_of => [ String, Array ]
