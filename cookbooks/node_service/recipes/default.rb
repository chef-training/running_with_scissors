#
# Cookbook:: lich_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory '/srv'

package 'unzip'

cookbook_file '/srv/lich.zip' do
  source 'lich.zip'
  notifies :run, 'execute[extract_site]', :immediately
  not_if { File.exist?('/srv/lich') }
end

execute 'extract_site' do
  command 'unzip lich.zip'
  cwd '/srv'
  not_if { File.exist?('/srv/lich') }
  action :nothing
end

package %w[gcc gcc-c++ sqlite-devel]

remote_file '/tmp/node-v10.1.0-linux-x64.tar.gz' do
  source 'http://nodejs.org/dist/v10.1.0/node-v10.1.0-linux-x64.tar.gz'
end

execute 'extract node' do
  cwd '/tmp'
  command 'tar --strip-components 1 -xzvf node-v10.1.0-linux-x64.tar.gz -C /usr/local'
  not_if { File.exist?('/usr/local/bin/node') }
end

execute 'install dependencies' do
  cwd '/srv/lich'
  command 'npm install'
end

execute 'migrate databate' do
  cwd '/srv/lich'
  command 'bin/migrate'
  notifies :create, 'file[/srv/lich/db_migrated]', :immediately
  not_if { File.exist?('/srv/lich/db_migrated') }
end

file '/srv/lich/db_migrated' do
  content 'migrated'
  action :nothing
end

template '/etc/systemd/system/lich.service' do
  source 'service.erb'
  variables({ service_name: 'lich', working_directory: '/srv/lich' })
end

template '/srv/lich/start.sh' do
  source 'start.sh.erb'
  mode '0774'
end

template '/srv/lich/stop.sh' do
  source 'stop.sh.erb'
  mode '0774'
end

service 'lich' do
  action :start
end
