#
# Cookbook:: specter_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


ruby_runtime '/srv/specter' do
  version '2.4'
  options :system, dev_package: true
end

directory '/srv' do
  recursive true
end

package 'unzip'

cookbook_file '/srv/specter.zip' do
  source 'specter.zip'
  notifies :run, 'execute[extract_site]', :immediately
end

execute 'extract_site' do
  command 'unzip specter.zip'
  action :nothing
  cwd '/srv'
end

application '/srv/specter' do

  # Install the dependencies
  bundle_install do
    deployment true
  end

  # Migrate the database
  # ruby_execute 'rake migrate'
  #
  # # Start the service
  # rackup do
  #   port 8000
  # end
end
