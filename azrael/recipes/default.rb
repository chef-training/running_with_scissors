#
# Cookbook:: azrael
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

node.default['audit'] = {
  'reporter' => 'json-file',
  'profiles' => [
    {
      "name" => "linux-baseline",
      "supermarket" => "dev-sec/linux-baseline"
    }
  ],
  'interval' => {
    'enabled' => false
  }
}

include_recipe 'audit'

directory '/etc/chef/handlers' do
  recursive true
end

cookbook_file '/etc/chef/handlers/upload_handler.rb' do
  source 'upload_handler.rb'
end

chef_gem 'faraday'

chef_handler 'Azrael::Handler::UploadFile' do
  source '/etc/chef/handlers/upload_handler.rb'
  arguments [ server: 'http://localhost:8000' ]
  supports report: true, exception: true
  action :enable
end
