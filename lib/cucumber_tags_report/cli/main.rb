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
    end
  end
end
