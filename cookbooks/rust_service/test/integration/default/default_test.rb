# encoding: utf-8

describe http('localhost:8000', enable_remote_worker: true) do
  its('status') { should eq 200 }
  its('body') { should match /friend/ }
end

# https://inspec.io/docs/reference/resources/command/
describe command('curl localhost:8000') do
  its('stdout') { should match /friend/ }
end

# https://inspec.io/docs/reference/resources/port/
describe port(8000) do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

# https://inspec.io/docs/reference/resources/command/
describe command('/root/.cargo/bin/cargo --version') do
  its('exit_status') { should eq 0 }
end

describe command('/root/.cargo/bin/diesel --version') do
  its('exit_status') { should eq 0 }
end
