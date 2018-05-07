# encoding: utf-8

# https://inspec.io/docs/reference/resources/http/
describe http('http://localhost:8000', enable_remote_worker: true) do
  its('status') { should eq 200 }
end

describe command('/usr/local/bin/ruby') do
  it { should exist }
end

describe command('/usr/local/bin/ruby -v') do
  its(:stdout) { should match(/2\.5\.1/) }
end

describe command('/usr/local/bin/bundle') do
  it { should exist }
end

describe command('/usr/local/bin/rackup') do
  it { should exist }
end
