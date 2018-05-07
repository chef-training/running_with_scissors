#
# Cookbook:: wraith_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y' do
  not_if { File.exist?('~/.rustup') }
end

directory '/srv' do
  recursive true
end

package 'unzip'

cookbook_file '/srv/wraith.zip' do
  source 'wraith.zip'
end

execute 'unpack_site' do
  cwd '/srv'
  command 'unzip wraith.zip'
  not_if { File.exist?('/srv/wraith') }
end

execute 'update && update' do
  cwd '/srv/wraith'
  command 'source /root/.bash_profile && rustup update && cargo update'
end

yum_package 'gcc'
execute 'yum groupinstall "Development Tools" -y'
package [ 'sqlite-devel', 'mysql-devel', 'postgresql-devel' ]

execute 'install diesel-cli' do
  cwd '/srv/wraith'
  command 'source /root/.bash_profile && cargo install diesel_cli'
  not_if { File.exist?('/root/.cargo/bin/diesel') }
end

execute 'database setup' do
  cwd '/srv/wraith'
  command 'source /root/.bash_profile && diesel setup && diesel migration run'
end

execute 'build' do
  cwd '/srv/wraith'
  command 'source /root/.bash_profile && cargo build'
end

# execute 'run' do
#   cwd '/srv/wraith'
#   # command 'source /root/.bash_profile && cargo run &'
# end

template '/etc/systemd/system/wraith.service' do
  source 'service.erb'
end

template '/srv/wraith/start.sh' do
  source 'start.sh.erb'
  mode '0777'
end

template '/srv/wraith/stop.sh' do
  source 'stop.sh.erb'
  mode '0777'
end

service 'wraith' do
  action :start
end
