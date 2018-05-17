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
    # TODO: A profile that looks the one that they developed but on the web
    # TODO: their profile zipped up and stored into the cookbook
    {
      "name" => "linux-baseline",
      "supermarket" => "dev-sec/linux-baseline"
    }
  ]
}

# @see https://docs.chef.io/resource_chef_handler.html

include_recipe 'audit'

chef_handler 'Azrael::Handler::UploadFile' do
  source "#{Chef::Config[:cookbook_path]}/#{cookbook_name}/files/default/upload_handler.rb"
  arguments [ server: 'http://localhost:8000' ]
  supports report: true, exception: true
  action :enable
end

# @see https://docs.chef.io/dsl_handler.html

Chef.event_handler do
  on :run_completed do
    # BASH Solution
    scan_path = "#{Chef::Config[:cookbook_path]}/audit/inspec-*.json"
    puts `curl -d @$(find . -name #{scan_path}) -H "Content-Type: application/json" http://localhost:8000/scans`

    # ShellOut Solution
    upload = Mixlib::ShellOut.new "curl -d @$(find . -name #{scan_path}) -H 'Content-Type: application/json' http://localhost:8000/scans"
    upload.run_command

    # Ruby/Chef Solution
    connection = Chef::HTTP.new('http://localhost:8000')
    headers = { 'Content-Type' => 'application/json' }

    Dir["#{Chef::Config[:cookbook_path]}/audit/inspec-*.json"].each do |scan_file|
      data = File.read(scan_file)
      connection.post("/scans", data.to_s, headers)
    end
  end
end
