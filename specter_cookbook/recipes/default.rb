#
# Cookbook:: specter_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

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
  not_if { File.exist?('/srv/specter') }
end

package %w[git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel]

remote_file '/tmp/ruby-2.5.1.tar.gz' do
  source 'https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz'
end

execute 'extract ruby' do
  cwd '/tmp'
  command 'tar -xvf ruby-2.5.1.tar.gz'
  not_if { File.exist?('/tmp/ruby-2.5.1') }
end

execute 'configure, make and install ruby' do
  cwd '/tmp/ruby-2.5.1'
  command './configure && make && make install'
  not_if { File.exist?('/usr/local/bin/ruby') }
end

execute 'install bundler' do
  command '/usr/local/bin/gem install bundler'
  not_if { File.exist?('/usr/local/bin/bundle') }
end

execute 'bundle install' do
  cwd '/srv/specter'
  command '/usr/local/bin/bundle install'
  not_if { File.exist?('/srv/specter/Gemfile.lock') }
end

template '/etc/systemd/system/specter.service' do
  source 'service.erb'
  variables({ service_name: 'specter', working_directory: '/srv/specter' })
end

template '/srv/specter/start.sh' do
  source 'start.sh.erb'
  mode '0774'
end

template '/srv/specter/stop.sh' do
  source 'stop.sh.erb'
  mode '0774'
end

service 'specter' do
  action :start
end
