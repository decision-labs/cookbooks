#
# Usage::
#   Use this to define anything you want sourced into /etc/make.conf
#
# Author:: Ho-Sheng Hsiao <hosh@sparkfly.com>
#          Benedikt Böhm <bb@xnull.de>
# Cookbook Name:: portage
# Definition:: make_conf
#
# Copyright 2010, Sparkfly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Overrides examples:
#   make_conf :rsync_excludes do
#     overrides => [ :PORTAGE_RSYNC_EXTRA_OPTS, '/etc/portage/chef/rsync_excludes', '/tmp/other_excludes' ]
#   end
#
#   make_conf :rackspace do
#     overrides [
#       [ :PORTAGE_RSYNC_EXTRA_OPTS, '/etc/portage/chef/rsync_excludes', '/tmp/other_excludes' ],
#       [ :GENTOO_MIRRORS, 'http://mirror.datapipe.net/gentoo', 'http://gentoo.cites.uiuc.edu/pub/gentoo/' ],
#       [ :PORTAGE_NICENESS, '19' ]
#     ]
#   end
#
# Appends examples:
#   make_conf :java do
#     appends [ :USE, 'java', 'ssl' ]
#   end
#
#   make_conf :chef_overlay do
#     appends [
#       [ :ACCEPT_LICENSE, 'dlj-1.1'], 
#       [ :PORTDIR_OVERLAY, '/usr/local/portage/chef-overlay' ],
#       [ :COLLISION_IGNORE, '/usr/bin/prettify_json.rb', '/usr/bin/edit_json.rb'],
#     ] 
#     overrides [ :RUBY_TARGETS, 'ruby18' ]
#   end
#
# Sources example:
#   make_conf :overlays do
#     sources %w( /usr/local/portage/layman/make.conf /usr/local/portage/site/make.conf )
#   end
#
# This definition generates a conf file that is sourced by /etc/portage/chef/make.conf
# This is intended to allow a mix of recipes, such as rsync_exclude, layman, site_rsync_mirror, binary_repository, etc.
# such that they get included in the make.conf which portage uses to emerge packages.

define :make_conf, :appends => [], :overrides => [], :sources => [], :force_regen => false do
  include_recipe 'portage'

  def map_override(list)
    env_var = list.shift
    [env_var, list.join(' ')]
  end

  def map_append(list)
    env_var, override = map_override(list)
    [env_var, "${#{env_var.to_s}} #{override}"]
  end

  def map_conf(conf_param, &block)
    if params[conf_param].any? && params[conf_param].first.is_a?(Symbol) then
      [ block.call(params[conf_param]) ]
    else
      params[conf_param].map { |element| block.call(element) }
    end
  end

  # Normalize overrides, appends, and sources for output
  overrides = map_conf(:overrides) { |e| map_override(e) }
  appends   = map_conf(:appends) { |e| map_append(e) }
  sources   = params[:sources].uniq

  extra_make_conf = "#{node[:portage][:make_conf]}.d/#{params[:name]}.conf"
  make_conf = resources(:template => node[:portage][:make_conf])

  # Wait until later to add the variables in. This makes changes to make.conf
  # atomically valid, otherwise emerge will barf.
  if params[:force_regen]
    ruby_block do
      block do
        make_conf.variables[:sources] << params[:name]
        make_conf.run_action(:create)
      end
    end
  else
    make_conf.variables[:sources] << params[:name]
  end

  template extra_make_conf do
    owner 'root'
    group 'root'
    mode '0644'
    source 'extra_make_conf.erb'
    cookbook "portage"
    variables(:overrides => overrides, :appends => appends, :sources => sources)
    subscribes :create, make_conf, :immediately
    backup 0
  end
end
