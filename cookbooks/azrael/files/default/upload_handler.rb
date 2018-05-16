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

      def audit_cookbook_scan_path
        File.join(Chef::Config[:cookbook_path], 'audit')
      end

      def report
        data = load_audit_inspec_json
        response_body = upload_json_data options[:server], data
        save_response(response_body)
      end

      private

      # The audit cookbook provides no mechanism to specify the file path of where it outputs the
      # JSON file. It is found within the cookbook's directory, relative to the handler file.
      def load_audit_inspec_json
        data = {}
        Dir[File.join(audit_cookbook_scan_path,'inspec-*.json')].each do |scan_filepath|
          data = File.read(scan_filepath)
        end
        data
      end

      def upload_json_data(reporting_server, data)
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
        response_body
      end

      def save_response(body)
        File.write('upload-response.txt',body)
      end

    end
  end
end
