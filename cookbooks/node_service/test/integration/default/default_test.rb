# encoding: utf-8

# https://inspec.io/docs/reference/resources/http/
describe http('localhost:8000', enable_remote_worker: true) do
  its('status') { should eq 200 }
end
