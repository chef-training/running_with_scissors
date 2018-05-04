#
# Cookbook:: lich_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

javascript_runtime '9.5.0'

directory '/srv' do
  recursive true
end

package 'unzip'

cookbook_file '/srv/lich.zip' do
  source 'lich.zip'
end

execute 'extract_site' do
  command 'unzip lich.zip'
  cwd '/srv'
end

application '/srv/lich' do
  npm_install
  npm_start
end
