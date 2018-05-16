# encoding: utf-8

# https://inspec.io/docs/reference/resources/http/
describe http('http://localhost:8000', enable_remote_worker: true) do
  its('status') { should eq 200 }
end

describe host('localhost', port: 8000, protocol: 'tcp') do
  it { should be_reachable }
  it { should be_resolvable }
end

describe port(8000) do
  it { should be_listening }
  its('processes') {should include 'ruby'}
end

describe command('/usr/local/bin/ruby') do
  it { should exist }
end

describe command('/usr/local/bin/ruby -v') do
  its(:stdout) { should match(/2\.5\.1/) }
  its(:stdout) { should match('2.5.1') }
end

describe command('/usr/local/bin/bundle') do
  it { should exist }
end

describe command('/usr/local/bin/rackup') do
  it { should exist }
end

describe service('specter') do
  it { should be_installed }
  it { should be_running }
end
