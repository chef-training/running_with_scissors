require 'chef/handler'
require 'json'
require 'faraday'

module Azrael
  module Handler
    class UploadFile < ::Chef::Handler
      def initialize(options = {})
        @options = options
      end

      attr_reader :options

      def reporting_server
        options[:server] || 'http://localhost:8000'
      end

      def report
        # Retrieve the data

        # The audit cookbook provides no mechanism to specify the file path of where it outputs the
        # JSON file. It is found within the cookbook's directory, relative to the handler file.

        data = "{}"

        Dir[File.join(Chef::Config[:cookbook_path],'audit/inspec-*.json')].each do |scan_filepath|
          data = File.read(scan_filepath)
        end

        # Upload the data

        # This is going to upload it to an application running locally on the system.

        connection = Faraday.new(url: reporting_server)
        response_body = ""

        begin
          response = connection.post do |req|
            req.url '/scans'
            req.headers['Content-Type'] = 'application/json'
            req.body = data
          end
          response_body = response.body
        rescue
          response_body = "FAILED TO CONTACT #{reporting_server}"
        end

        # Write the response

        File.write('upload-response.txt',response_body)
      end
    end
  end
end
