require 'spec_helper'


describe "Azrael::Handler::UploadFile" do

  let(:handler_file) { 'files/default/upload_handler.rb' }
  let(:described_class) { Azrael::Handler::UploadFile }

  let(:options) do
    { server: 'http://localhost:3000' }
  end

  let(:handler) do
    require_relative File.join('..','..','..',handler_file)
    described_class.new(options)
  end

  context '#reports' do
    before do
      allow(handler).to receive(:load_audit_inspec_json).and_return(scan_data)
      allow(handler).to receive(:upload_json_data).and_return(upload_results)
      allow(handler).to receive(:save_response)
    end

    let(:scan_data) { "{}" }
    let(:upload_results) { "SUCCESS" }

    it 'reports without error' do
      expect { handler.report }.to_not raise_error
    end

    it 'loads the audit scan file' do
      handler.report
      expect(handler).to have_received(:load_audit_inspec_json)
    end

    it 'sends the scan results to the specified target' do
      handler.report
      expect(handler).to have_received(:upload_json_data).with(options[:server],scan_data)
    end

    it 'writes results to the file system' do
      handler.report
      expect(handler).to have_received(:save_response).with(upload_results)
    end
  end
end
