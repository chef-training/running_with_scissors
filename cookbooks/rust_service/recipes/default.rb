#
# Cookbook:: rust_service
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory '/srv'

package 'unzip'

cookbook_file '/srv/wraith.zip' do
  source 'wraith.zip'
  notifies :run, 'execute[extract_site]', :immediately
end

execute 'extract_site' do
  cwd '/srv'
  command 'unzip wraith.zip'
  not_if { File.exist?('/srv/wraith') }
  action :nothing
end

execute 'install rust nightly' do
  command 'curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y'
  not_if { File.exist?('~/.rustup') }
end

execute 'update && update' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/rustup update && /root/.cargo/bin/cargo update'
end

execute 'yum groupinstall "Development Tools" -y'

package [ 'sqlite-devel', 'mariadb-devel', 'postgresql-devel' ]

execute 'install diesel-cli' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/cargo install diesel_cli'
  not_if { File.exist?('/root/.cargo/bin/diesel') }
end

execute 'database setup' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/diesel setup && /root/.cargo/bin/diesel migration run'
end

execute 'build' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/cargo build'
end

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
