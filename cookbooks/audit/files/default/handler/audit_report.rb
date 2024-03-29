require 'chef/handler'
include ReportHelpers

class Chef
  class Handler
    # Creates a compliance audit report
    class AuditReport < ::Chef::Handler
      MIN_INSPEC_VERSION = '1.25.1'.freeze

      def self.reporter(name,&block)
        reporters[name] = block
      end

      def self.reporters
        @reporters ||= begin
          hash = Hash.new
          hash.default = -> (opts) {
            Chef::Log.warn "#{opts[:reporter]} is not a supported InSpec report collector"
          }
          hash
        end
      end

      reporter 'file' do |opts|
        timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        filename = 'inspec' << '-' << timestamp << '.json'
        opts[:path] = File.expand_path("../../../../#{filename}", __FILE__)
        Chef::Log.info "Writing report to #{opts[:path]}"
        Reporter::JsonFile.new({ file: opts[:path] }).send_report(opts[:report])
      end

      def initialize

      end

      def load_handlers

      end

      def audit
        node['audit']
      end

      def report
        reporters = get_reporters(audit)

        warn_if_deprecated_reporters(reporters)

        # collect attribute values
        server = audit['server']
        results_format = audit['format'] || 'json'
        user = audit['owner']
        token = audit['token']
        refresh_token = audit['refresh_token']
        interval = audit['interval']
        interval_enabled = audit['interval']['enabled']
        interval_time = audit['interval']['time']
        profiles = audit['profiles']
        quiet = audit['quiet']
        fetcher = audit['fetcher']
        attributes = audit['attributes'].to_h
        insecure = audit['insecure']
        raise_if_unreachable = audit['raise_if_unreachable']

        # add chef node data as an attribute if enabled
        attributes['chef_node'] = chef_node_attribute_data if node['audit']['chef_node_attribute_enabled']

        # load inspec, supermarket bundle and compliance bundle
        load_needed_dependencies

        # confirm our inspec version is valid
        validate_inspec_version

        fetcher = audit['fetcher']

        # detect if we run in a chef client with chef server
        load_chef_fetcher if reporters.include?('chef-server') ||
                             reporters.include?('chef-server-compliance') ||
                             reporters.include?('chef-server-visibility') ||
                             reporters.include?('chef-server-automate') ||
                             %w{chef-server chef-server-compliance chef-server-visibility chef-server-automate}.include?(fetcher)

        load_automate_fetcher if fetcher == 'chef-automate'

        server = audit['server']
        user = audit['owner']
        token = audit['token']
        refresh_token = audit['refresh_token']

        # ensure authentication for Chef Compliance is in place, see libraries/compliance.rb
        login_to_compliance(server, user, token, refresh_token) if reporters.include?('chef-compliance')

        interval = audit['interval']
        interval_enabled = audit['interval']['enabled']
        interval_time = audit['interval']['time']

        # true if profile is due to run (see libraries/helper.rb)
        if check_interval_settings(interval, interval_enabled, interval_time)

          # create a file with a timestamp to calculate interval timing
          create_timestamp_file if interval_enabled

          results_format = audit['format'] || 'json'
          quiet = audit['quiet']
          attributes = audit['attributes'].to_h

          # return hash of opts to be used by runner
          scan_opts = get_opts(results_format, quiet, attributes)

          profiles = audit['profiles']

          # instantiate inspec runner with given options and run profiles; return report
          report = call(scan_opts, profiles)

          insecure = audit['insecure']
          raise_if_unreachable = audit['raise_if_unreachable']

          # send report to the correct reporter (automate, compliance, chef-server)
          if !report.empty?
            opts = {
              server: server,
              user: user,
              insecure: insecure,
              raise_if_unreachable: raise_if_unreachable,
              # WHY: the same but name-changed for some reason
              source_location: profiles,
              # The resulting report
              report: report,
              # The node related information
              entity_uuid: run_status.entity_uuid,
              run_id: run_status.run_id,
              node_info: gather_nodeinfo
            }

            reporters.each do |reporter|
              instance_exec(opts,&self.class.reporters[reporter])
              # reporter_action[reporter].call(opts)
            end
          else
            Chef::Log.error 'Audit report was not generated properly, skipped reporting'
          end
        else
          Chef::Log.info 'Audit run skipped due to interval configuration'
        end
      end

      def warn_if_deprecated_reporters(reporters)
        if reporters.include?('chef-visibility')
          Chef::Log.warn 'reporter `chef-visibility` is deprecated and removed in audit cookbook 4.0. Please use `chef-automate`.'
        end

        if reporters.include?('chef-server-visibility')
          Chef::Log.warn 'reporter `chef-server-visibility`is deprecated and removed in audit cookbook 4.0. Please use `chef-server-automate`.'
        end
      end

      # overwrite the default run_report_safely to be able to throw exceptions
      def run_report_safely(run_status)
        run_report_unsafe(run_status)
      rescue Exception => e # rubocop:disable Lint/RescueException
        Chef::Log.error("Report handler #{self.class.name} raised #{e.inspect}")
        Array(e.backtrace).each { |line| Chef::Log.error(line) }
        # force a chef-client exception if user requested it
        throw e if node['audit']['fail_if_not_present']
      ensure
        @run_status = nil
      end

      def validate_inspec_version
        minimum_ver_msg = "This audit cookbook version requires InSpec #{MIN_INSPEC_VERSION} or newer, aborting compliance scan..."
        raise minimum_ver_msg if Gem::Version.new(::Inspec::VERSION) < Gem::Version.new(MIN_INSPEC_VERSION)

        # check if we have a valid version for backend caching
        backend_cache_msg = 'inspec_backend_cache requires InSpec version >= 1.47.0'
        Chef::Log.warn backend_cache_msg if node['audit']['inspec_backend_cache'] &&
                                            (Gem::Version.new(::Inspec::VERSION) < Gem::Version.new('1.47.0'))
      end

      def load_needed_dependencies
        require 'inspec'
        # load supermarket plugin, this is part of the inspec gem
        require 'bundles/inspec-supermarket/api'
        require 'bundles/inspec-supermarket/target'

        # load the compliance plugin
        require 'bundles/inspec-compliance/configuration'
        require 'bundles/inspec-compliance/support'
        require 'bundles/inspec-compliance/http'
        require 'bundles/inspec-compliance/api'
        require 'bundles/inspec-compliance/target'
      end

      # we expect inspec to be loaded before
      def load_chef_fetcher
        Chef::Log.debug "Load Chef Server fetcher from: #{cookbook_vendor_path}"
        $LOAD_PATH.unshift(cookbook_vendor_path)
        require 'chef-server/fetcher'
      end

      def load_automate_fetcher
        Chef::Log.debug "Load Chef Automate fetcher from: #{cookbook_vendor_path}"
        $LOAD_PATH.unshift(cookbook_vendor_path)
        require 'chef-automate/fetcher'
      end

      def get_opts(report_format, quiet, attributes)
        output = quiet ? ::File::NULL : $stdout
        Chef::Log.debug "Format is #{report_format}"
        opts = {
          'report' => true,
          'format' => report_format,
          'output' => output,
          'logger' => Chef::Log, # Use chef-client log level for inspec run,
          backend_cache: node['audit']['inspec_backend_cache'],
          attributes: attributes,
        }
        opts
      end

      # run profiles and return report
      def call(opts, profiles)
        Chef::Log.info "Using InSpec #{::Inspec::VERSION}"
        Chef::Log.debug "Options are set to: #{opts}"
        runner = ::Inspec::Runner.new(opts)

        # parse profile hashes for runner, see libraries/helper.rb
        tests = tests_for_runner(profiles)
        if !tests.empty?
          tests.each { |target| runner.add_target(target, opts) }

          Chef::Log.info "Running tests from: #{tests.inspect}"
          runner.run
          r = runner.report

          # output summary of InSpec Report in Chef Logs
          if !r.nil? && 'json-min' == opts['format']
            time = 0
            time = r[:statistics][:duration] unless r[:statistics].nil?
            passed_controls = r[:controls].select { |c| c[:status] == 'passed' }.size
            failed_controls = r[:controls].select { |c| c[:status] == 'failed' }.size
            skipped_controls = r[:controls].select { |c| c[:status] == 'skipped' }.size
            Chef::Log.info "Summary: #{passed_controls} successful, #{failed_controls} failures, #{skipped_controls} skipped in #{time} s"
          end

          Chef::Log.debug "Audit Report #{r}"
          r
        else
          Chef::Log.warn 'No audit tests are defined.'
          {}
        end
      rescue Inspec::FetcherFailure => e
        Chef::Log.error e.message
        Chef::Log.error "We cannot fetch all profiles: #{tests}. Please make sure you're authenticated and the server is reachable."
        {}
      end

      # extracts relevant node data
      def gather_nodeinfo
        n = run_context.node
        runlist_roles = n.run_list.select { |item| item.type == :role }.map(&:name)
        runlist_recipes = n.run_list.select { |item| item.type == :recipe }.map(&:name)
        {
          node: n.name,
          os: {
            release: n['platform_version'],
            family: n['platform'],
          },
          environment: n.environment,
          roles: runlist_roles,
          recipes: runlist_recipes,
        }
      end

      def reporter_action
        hash = Hash.new

        not_supported_action = lambda do |opts|
          Chef::Log.warn "#{opts[:reporter]} is not a supported InSpec report collector"
        end

        automate_action = lambda do |opts|
          Reporter::ChefAutomate.new(opts).send_report(opts[:report])
        end

        chef_server_automate_action = lambda do |opts|
          chef_url = opts[:server] || base_chef_server_url
          if chef_url
            chef_org = Chef::Config[:chef_server_url].split('/').last
            opts[:url] = construct_url(chef_url, File.join('organizations', chef_org, 'data-collector'))
            Reporter::ChefServerAutomate.new(opts).send_report(opts[:report])
          else
            Chef::Log.warn "unable to determine chef-server url required by inspec report collector '#{opts[:reporter]}'. Skipping..."
          end
        end

        chef_server_compliance_action = lambda do |opts|
          chef_url = opts[:server] || base_chef_server_url
          if chef_url
            chef_org = Chef::Config[:chef_server_url].split('/').last
            opts[:url] = construct_url(chef_url + '/compliance/', File.join('organizations', chef_org, 'inspec'))
            Reporter::ChefServerCompliance.new(opts).send_report(opts[:report])
          else
            Chef::Log.warn "unable to determine chef-server url required by inspec report collector '#{opts[:reporter]}'. Skipping..."
          end
        end

        chef_compliance_action = lambda do |opts|
          if opts[:server]
            opts[:url] = construct_url(opts[:server], File.join('/owners', opts[:user], 'inspec'))
            compliance_config = Compliance::Configuration.new
            opts[:token] = compliance_config['token']
            Reporter::ChefCompliance.new(opts).send_report(opts[:report])
          else
            Chef::Log.warn "'server' and 'token' properties required by inspec report collector #{opts[:reporter]}. Skipping..."
          end
        end

        json_file_action = lambda do |opts|
          timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
          filename = 'inspec' << '-' << timestamp << '.json'
          path = File.expand_path("../../../../#{filename}", __FILE__)
          Chef::Log.info "Writing report to #{path}"
          Reporter::JsonFile.new({ file: path }).send_report(opts[:report])
        end

        hash.default = not_supported_action

        hash['chef-visibility'] = automate_action
        hash['chef-automate'] = automate_action

        hash['chef-server-visibility'] = chef_server_automate_action
        hash['chef-server-automate'] = chef_server_automate_action

        hash['chef-compliance'] = chef_compliance_action

        hash['chef-server-compliance'] = chef_server_compliance_action
        hash['chef-server'] = chef_server_compliance_action

        hash['json-file'] = json_file_action

        file_action = lambda do |opts|
          timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
          filename = 'inspec' << '-' << timestamp << '.json'
          opts[:path] = File.expand_path("../../../../#{filename}", __FILE__)
          Chef::Log.info "Writing report to #{opts[:path]}"
          Reporter::JsonFile.new({ file: opts[:path] }).send_report(opts[:report])
        end

        hash['file'] = file_action

        hash
      end

      # Gather Chef node attributes, etc. for passing to the InSpec run
      def chef_node_attribute_data
        node_data = node.to_h
        node_data['chef_environment'] = node.chef_environment

        node_data
      end
    end
  end
end
