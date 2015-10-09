require 'spec_helper'
require 'cucumber_tags_report/formatter/spec_helper'
require 'cucumber_tags_report/fomatter/tags_list'
require 'nokogiri'
require 'rspec/mocks'

module CucumberTagsReport
  module Formatter
    describe TagsList do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        @out = StringIO.new
        @formatter = TagsList.new(runtime, @out, {})
      end
      describe 'Given a single scenario in the feature file' do

        define_feature <<-FEATURE
          Feature: Banana Joe

            @Release2016.3.0
            @PB-12345-08
            Scenario: Monkey eats bananas
              When I start a new scenario
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it { expect(@result).to match_array(['@Release2016.3.0', '@PB-12345-08']) }
      end

      describe 'Given a multiple scenarios in the feature file' do

        define_feature <<-FEATURE
          Feature: Banana Joe

            @Release2016.3.0
            @PB-12345-01
            Scenario: Monkey eats bananas
              When I start a new scenario

            @Release2016.3.0
            @PB-12345-02
            Scenario: Monkey eats bananas
              When I restart last scenario
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it { expect(@result).to match_array(['@Release2016.3.0', '@PB-12345-01', '@PB-12345-02']) }
      end

      describe 'Given a scenario without tags in the feature file' do

        define_feature <<-FEATURE
          Feature: Banana Joe

            Scenario: Monkey eats bananas
              When I start a new scenario
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it { expect(@result).to match_array([]) }
      end
    end
  end
end
