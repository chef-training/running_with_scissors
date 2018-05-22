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

execute 'install rustup default nightly' do
  command 'curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y'
  not_if { File.exist?('~/.rustup') }
end

execute 'yum groupinstall "Development Tools" -y'

package [ 'sqlite-devel' ]

execute 'install dependencies' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/cargo install --force'
end

execute 'install diesel-cli' do
  cwd '/srv/wraith'
  command '/root/.cargo/bin/cargo install diesel_cli --version 1.2.0 --no-default-features --features "sqlite"'
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
