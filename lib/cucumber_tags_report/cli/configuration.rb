require_relative 'options'
require 'cucumber'
require 'cucumber/cli/configuration'

module CucumberTagsReport
  module Cli
    class Configuration < Cucumber::Cli::Configuration
      attr_reader :out_stream

      def initialize(out_stream = STDOUT, error_stream = STDERR)
        @out_stream   = out_stream
        @error_stream = error_stream
        @options = CucumberTagsReport::Cli::Options.new(@out_stream, @error_stream, :default_profile => 'default')
      end
    end
  end
end
