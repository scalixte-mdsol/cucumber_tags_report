require 'spec_helper'
require 'yaml'
require 'cucumber'
require 'cucumber/parser/gherkin_builder'
require 'gherkin/formatter/model'
require 'cucumber_tags_report/cli/main'

module CucumberTagsReport
  module Cli
    describe Main do
      before(:each) do
        File.stub(:exist?).and_return(false) # When Configuration checks for cucumber.yml
        Dir.stub(:[]).and_return([]) # to prevent cucumber's features dir to being laoded
      end

      let(:args) { [] }
      let(:stdin) { StringIO.new }
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:kernel) { double(:kernel) }
      subject { Main.new(args, stdin, stdout, stderr, kernel) }

      describe "#execute!" do
        context "passed an existing runtime" do
          let(:existing_runtime) { double('runtime').as_null_object }

          def do_execute
            subject.execute!(existing_runtime)
          end

          # it "configures that runtime" do
          #   expected_configuration = double('Configuration', :drb? => false).as_null_object
          #   Configuration.stub(:new => expected_configuration)
          #   existing_runtime.should_receive(:configure).with(expected_configuration)
          #   kernel.should_receive(:exit).with(1)
          #   do_execute
          # end

          it "uses that runtime for running and reporting results" do
            expected_results = double('results', :failure? => true)
            existing_runtime.should_receive(:run!)
            existing_runtime.stub(:results).and_return(expected_results)
            kernel.should_receive(:exit).with(1)
            do_execute
          end
        end
      end
    end
  end
end
