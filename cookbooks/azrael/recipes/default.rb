#
# Cookbook:: azrael
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# @see https://github.com/chef-cookbooks/audit

node.default['audit'] = {
  'reporter' => 'json-file',
  'interval' => { 'enabled' => false },
  'profiles' => [
    # TODO: add the profile provided through GitHub
    # {
    #   'name' => 'profile-name',
    #   'git' => 'https://github.com/origin/repo.git'
    # }
    # {
    #   'name' => 'profile-name',
    #   'url' => 'https://github.com/origin/repo/archive/master.zip'
    # }

    # TODO: add the profile that you archived and stored in the profile
  ]
}

include_recipe 'audit'

# This is the path with the wildcard path that points to the JSON results
scan_path = "#{Chef::Config[:cookbook_path]}/audit/inspec-*.json"

# @see https://docs.chef.io/dsl_handler.html

# @see https://docs.chef.io/resource_chef_handler.html
