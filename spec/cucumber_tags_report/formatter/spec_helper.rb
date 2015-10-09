module CucumberTagsReport
  module Formatter
    module SpecHelperDsl
      attr_reader :feature_content, :step_defs, :feature_filename

      def define_feature(string, feature_file = 'spec.feature')
        @feature_content = string
        @feature_filename = feature_file
      end

      def define_steps(&block)
        @step_defs = block
      end
    end

    require 'cucumber/core'
    module SpecHelper
      include Cucumber::Core

      def run_defined_feature
        define_steps
        runtime.visitor = report

        receiver = Test::Runner.new(report)
        filters = [
            Cucumber::Filters::ActivateSteps.new(runtime.support_code),
            Cucumber::Filters::ApplyAfterStepHooks.new(runtime.support_code),
            Cucumber::Filters::ApplyBeforeHooks.new(runtime.support_code),
            Cucumber::Filters::ApplyAfterHooks.new(runtime.support_code),
            Cucumber::Filters::ApplyAroundHooks.new(runtime.support_code),
            Cucumber::Filters::PrepareWorld.new(runtime)
        ]
        compile [gherkin_doc], receiver, filters
      end

      require 'cucumber/formatter/legacy_api/adapter'
      def report
        @report ||= Cucumber::Formatter::LegacyApi::Adapter.new(
            Cucumber::Formatter::Fanout.new([@formatter]),
            runtime.results,
            runtime.support_code,
            runtime.configuration)
      end

      require 'cucumber/core/gherkin/document'
      def gherkin_doc
        Cucumber::Core::Gherkin::Document.new(self.class.feature_filename, gherkin)
      end

      def gherkin
        self.class.feature_content || raise("No feature content defined!")
      end

      require 'cucumber/runtime'
      def runtime
        @runtime ||= Cucumber::Runtime.new
      end

      def define_steps
        return unless step_defs = self.class.step_defs
        rb = runtime.load_programming_language('rb')
        dsl = Object.new
        dsl.extend RbSupport::RbDsl
        dsl.instance_exec &step_defs
      end
    end
  end
end
