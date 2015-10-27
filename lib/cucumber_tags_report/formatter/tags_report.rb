require 'multi_json'
require 'base64'
require 'cucumber/formatter/io'
require 'cucumber/formatter/console'
require_relative '../report_generator'

module CucumberTagsReport
  module Formatter
    class TagsReport
      attr_reader :scenario_hashes, :scenario_tags, :scenario_hash, :feature_hash, :io, :options, :runtime, :report
      include Cucumber::Formatter::Io
      include Cucumber::Formatter::Console

      def initialize(runtime, path_or_io, options)
        @runtime = runtime
        @options = options
        @io = ensure_io(path_or_io, "tags_report")

        @report = ReportGenerator.new(options[:report]) if options[:report]

        @scenario_tags = []
        @scenario_hashes = []
        @scenario_hash = {}
        @feature_hash = {}
      end

      def before_features(features)
      end

      def before_feature(feature)
        create_feature(feature)
      end

      def before_feature_element(feature_element)
        case feature_element
          when Cucumber::Ast::Scenario, Cucumber::Ast::ScenarioOutline
            create_scenario(feature_element)
        end
      end

      def after_feature_element(feature_element)
        case feature_element
          when Cucumber::Ast::Scenario, Cucumber::Ast::ScenarioOutline
            @scenario_hashes << @scenario_hash
            @scenario_hash = {}
        end
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @scenario_hash.merge!({complete_description: name})
      end

      def after_feature(feature)
        @feature_hash = {}
      end

      def after_features(features)
        done
      end

      private

      def done
        @io.write(MultiJson.dump(@scenario_hashes, pretty: true))
        @report.try(:generate_report, scenario_hashes)
      end

      def current_feature
        @feature_hash ||= {}
      end

      def same_feature_as_previous_test_case?(feature)
        current_feature[:uri] == feature.file && current_feature[:line] == feature.location.line
      end

      def create_feature(feature)
        unless same_feature_as_previous_test_case?(feature)
          current = feature.gherkin_statement.to_hash
          @feature_hash = {
              uri: feature.file,
              filename: File.basename(feature.file),
              id: SecureRandom.hex,
              keyword: current['keyword'],
              title: current['name'],
              description: current['description'],
              line: current['line'],
              tags: (current['tags'].collect { |tag| tag['name'] } if current['tags']) || []
          }

        end
      end

      def create_scenario(scenario)
        hash = scenario.gherkin_statement.to_hash
        @scenario_hash ||= {}
        @scenario_hash.merge!({
                                  uri: @feature_hash[:uri],
                                  filename: @feature_hash[:filename],
                                  id: SecureRandom.hex,
                                  keyword: hash['keyword'],
                                  title: hash['name'],
                                  description: hash['description'],
                                  line: hash['line'],
                                  scenario_line: "Scenario: #{hash['line']}",
                                  tags: (hash['tags'].collect { |tag| tag['name'] } if hash['tags']) || []
                              })
        @scenario_hash[:tags] += @feature_hash[:tags]
      end
    end
  end
end
