require 'cucumber/cli/options'

module CucumberTagsReport
  module Cli
    class Options < Cucumber::Cli::Options
      BUILTIN_FORMATS.merge!({
                                 'tags_report' => ['CucumberTagsReport::Formatter::TagsReport', 'Generates a nice looking JSON tags report.'],
                                 'tags_list' => ['CucumberTagsReport::Formatter::TagsList', 'Generates a list tags.']
                             })
    end
  end
end
