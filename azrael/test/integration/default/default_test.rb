# encoding: utf-8

# https://inspec.io/docs/reference/resources/file/
describe file('/upload-response.txt') do
  it { should exist }
  its('content') { should eq 'FAILED TO CONTACT http://localhost:8000' }
end
