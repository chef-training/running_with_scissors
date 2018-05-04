# encoding: utf-8

# https://inspec.io/docs/reference/resources/http/
describe http('http://localhost:8000') do
  its('status') { should eq 200 }
end
