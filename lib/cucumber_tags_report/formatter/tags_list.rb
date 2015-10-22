require 'multi_json'
require 'base64'
require 'cucumber/formatter/io'
require 'cucumber/formatter/console'

module CucumberTagsReport
  module Formatter
    class TagsList
      attr_reader :all_tags, :io, :options, :runtime
      include Cucumber::Formatter::Io
      include Cucumber::Formatter::Console

      def initialize(runtime, path_or_io, options)
        @runtime = runtime
        @options = options
        @io = ensure_io(path_or_io, "tags_list")
        @all_tags = []
        @io.puts options.instance_variables
        # @io.puts options.args
        @io.puts options.options
        # options.args.each {|k,v| @io.puts "#{k} #{v} "}
      end

      def tag_name(tag_name)
        @all_tags << tag_name
      end

      def after_features(features)
        done
      end

      private

      def done
        @all_tags.uniq.sort.each { |tag| @io.puts tag }
      end

    end
  end
end
