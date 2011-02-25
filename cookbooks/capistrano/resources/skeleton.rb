def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create

attribute :homedir, :kind_of => String
attribute :uid, :kind_of => Integer
attribute :groups, :kind_of => Array, :default => ['cron']
attribute :shared, :kind_of => Array, :default => []
attribute :rvm, :kind_of => String, :default => nil
attribute :ruby, :kind_of => Hash, :default => nil
