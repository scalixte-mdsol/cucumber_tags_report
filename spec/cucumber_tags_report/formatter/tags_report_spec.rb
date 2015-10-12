require 'spec_helper'
require 'cucumber_tags_report/formatter/spec_helper'
require 'cucumber_tags_report/formatter/tags_report'
require 'nokogiri'
require 'rspec/mocks'
require 'cucumber/rb_support/rb_language'

module CucumberTagsReport
  module Formatter
    describe TagsReport do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        @out = StringIO.new
        @formatter = TagsReport.new(runtime, @out, {})
        runtime.visitor = @formatter
      end

      describe 'Given a single scenario' do

        define_feature <<-FEATURE
          @Core
          Feature: Banana Joe
            Description: Joe the monkey, eats bananas

            @Release2016.3.0
            @PB-12345-08
            Scenario: Monkey eats bananas
              Description: Joe has come to eat bananas
              Given Joe has come to the forest
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it "outputs the json data" do
          expect(load_normalised_json(@out)).to eq MultiJson.load(
                                                       %{[{"uri":"spec.feature", "id":"banana-joe;monkey-eats-bananas", "keyword":"Scenario", "title":"Monkey eats bananas", "description":"Description: Joe has come to eat bananas", "line":7, "tags":["@Release2016.3.0", "@PB-12345-08", "@Core"], "complete_description":"Monkey eats bananas\\nDescription: Joe has come to eat bananas"}
]})
        end
      end

      describe 'Given a single scenario outline' do

        define_feature <<-FEATURE
          @Core
          Feature: Banana Joe
            Description: Joe the monkey, eats fruits

            @Release2016.3.0
            @PB-12345-08
            Scenario Outline: Monkey eats fruits
              Description: Joe has come to eat bananas
              Given Joe has come to the forest
              Then Joe can <fruit>
              Examples:
              | fruit   |
              | bananas |
              | apples  |
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it "outputs the json data" do
          expect(load_normalised_json(@out)).to eq MultiJson.load(%{
  [{"uri": "spec.feature", "id": "banana-joe;monkey-eats-fruits", "keyword": "Scenario Outline",  "title": "Monkey eats fruits", "description": "Description: Joe has come to eat bananas", "line": 7, "tags": ["@Release2016.3.0", "@PB-12345-08", "@Core"], "complete_description": "Monkey eats fruits\\nDescription: Joe has come to eat bananas"}]
})
        end
      end

      describe 'Given multiple scenarios ' do

        define_feature <<-FEATURE
          Feature: Banana Joe

            @Release2016.3.0
            @PB-12345-01
            Scenario: Monkey eats bananas
              Description: Joe has come to eat bananas
              Given Joe has come to the forest
              Then Joe eats the bananas

            @Release2016.3.0
            @PB-12345-02
            Scenario Outline: Monkey eats fruits
              Description: Joe has come to eat bananas
              Given Joe has come to the forest
              Then Joe can <fruit>
              Examples:
              | fruit   |
              | bananas |
              | apples  |
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it "outputs the json data" do
          expect(load_normalised_json(@out)).to eq MultiJson.load(%{
[{
    "uri": "spec.feature",
    "id": "banana-joe;monkey-eats-bananas",
    "keyword": "Scenario",
    "title": "Monkey eats bananas",
    "description": "Description: Joe has come to eat bananas",
    "line": 5,
    "tags": ["@Release2016.3.0", "@PB-12345-01"],
    "complete_description": "Monkey eats bananas\\nDescription: Joe has come to eat bananas"
  },
  {
    "uri": "spec.feature",
    "id": "banana-joe;monkey-eats-fruits",
    "keyword": "Scenario Outline",
    "title": "Monkey eats fruits",
    "description": "Description: Joe has come to eat bananas",
    "line": 12,
    "tags": ["@Release2016.3.0", "@PB-12345-02"],
    "complete_description": "Monkey eats fruits\\nDescription: Joe has come to eat bananas"
  }]
})
        end
      end

      describe 'Given a scenario with no tags' do

        define_feature <<-FEATURE
          Feature: Banana Joe

            Scenario: Monkey eats bananas
              Description: Joe has come to eat bananas
              Given Joe has come to the forest
        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it "outputs the json data" do
          expect(load_normalised_json(@out)).to eq MultiJson.load(%{
[{
    "uri": "spec.feature",
    "id": "banana-joe;monkey-eats-bananas",
    "keyword": "Scenario",
    "title": "Monkey eats bananas",
    "description": "Description: Joe has come to eat bananas",
    "line": 3,
    "tags": [],
    "complete_description": "Monkey eats bananas\\nDescription: Joe has come to eat bananas"
  }]
})
        end
      end

      describe 'Given a feature with no scenario' do

        define_feature <<-FEATURE
          Feature: Banana Joe
            Description: Joe the monkey, eats bananas

        FEATURE

        before(:each) do
          run_defined_feature
          @result = @out.string.split
        end

        it "outputs the json data" do
          expect(load_normalised_json(@out)).to eq MultiJson.load(%{[]})
        end

      end

      def load_normalised_json(out)
        MultiJson.load(out.string)
      end
    end
  end
end
