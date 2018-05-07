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
  its('protocols') { should include('tcp6') }
end

# https://inspec.io/docs/reference/resources/command/
describe command('source /root/.bash_profile && cargo') do
  its('exit_status') { should_not eq 0 }
end

describe command('source /root/.bash_profile && diesel') do
  its('exit_status') { should_not eq 0 }
end
