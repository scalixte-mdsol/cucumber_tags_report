require 'multi_json'
require 'base64'
require 'cucumber/formatter/io'
require 'cucumber/formatter/console'
# require 'cucumber/formatter/hook_query_visitor'

module CucumberTagsReport
  module Formatter
    class TagsList
      attr_reader :all_tags, :path_or_io, :io, :options, :runtime
      include Cucumber::Formatter::Io
      include Cucumber::Formatter::Console

      def initialize(runtime, path_or_io, options)
        @runtime = runtime
        @options = options
        @io = ensure_io(path_or_io, "list_scenario_tags")
        @all_tags = []
      end

      def tag_name(tag_name, all_tags = [])
        @all_tags << tag_name
      end

      def after_features(features)
        # create_csv_report(@all_tags.inject(Hash.new(0)) { |hash, value| hash[value] += 1; hash })
        @all_tags.uniq.sort.each { |tag| @io.puts tag }
      end

    end
  end
end