#
# Rakefile for Chef Server Repository
#

require 'rubygems'
require 'chef'
require 'json'

# load constants from rake config file.
require File.join(File.dirname(__FILE__), 'config', 'rake')

# load chef config
begin
  Chef::Config.from_file(File.join(ENV['HOME'], '.chef', 'knife.rb'))
rescue
  # do nothing
end

# monkeypatch Rake module to remove built-in tasks easily
module Rake
  def self.remove_task(task_name)
    Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
  end
end

# Detect the version control system and assign to $vcs. Used by the update
# task in chef_repo.rake (below). The install task calls update, so this
# is run whenever the repo is installed.
if File.directory?(File.join(TOPDIR, ".svn"))
  $vcs = :svn
elsif File.directory?(File.join(TOPDIR, ".git"))
  $vcs = :git
end

# Load common, useful tasks from Chef.
# rake -T to see the tasks this loads.
load 'chef/tasks/chef_repo.rake'

Rake.remove_task 'ssl_cert'

Dir[ File.join(File.dirname(__FILE__), 'tasks', '*.rake') ].sort.each do |f|
    load f
end
