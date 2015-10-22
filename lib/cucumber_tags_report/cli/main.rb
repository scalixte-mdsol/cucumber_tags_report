begin
  require 'gherkin'
rescue LoadError
  require 'rubygems'
  require 'gherkin'
end

require_relative 'configuration'
require 'cucumber'
require 'cucumber/cli/main'

module CucumberTagsReport
  module Cli
    class Main < Cucumber::Cli::Main
      class << self
        def execute(args)
          new(args).execute!
        end
      end

      def configuration
        return @configuration if @configuration

        @configuration = CucumberTagsReport::Cli::Configuration.new(@out, @err)
        @configuration.parse!(@args)
        Cucumber.logger = @configuration.log
        @configuration
      end

    end
  end
end
