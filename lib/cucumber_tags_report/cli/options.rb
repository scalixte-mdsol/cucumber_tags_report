require 'cucumber'
require 'cucumber/cli/options'

module CucumberTagsReport
  module Cli
    class Options < Cucumber::Cli::Options
      BUILTIN_FORMATS.merge!({
                                 'tags_report' => ['CucumberTagsReport::Formatter::TagsReport', 'Generates a nice looking JSON tags report.'],
                                 'tags_list' => ['CucumberTagsReport::Formatter::TagsList', 'Generates a list tags.']
                             })
      max = BUILTIN_FORMATS.keys.map { |s| s.length }.max
      FORMAT_HELP = (BUILTIN_FORMATS.keys.sort.map do |key|
        "  #{key}#{' ' * (max - key.length)} : #{BUILTIN_FORMATS[key][1]}"
      end) + ["Use --format rerun --out features.txt to write out failing",
              "features. You can rerun them with cucumber @rerun.txt.",
              "FORMAT can also be the fully qualified class name of",
              "your own custom formatter. If the class isn't loaded,",
              "Cucumber will attempt to require a file with a relative",
              "file name that is the underscore name of the class name.",
              "Example: --format Foo::BarZap -> Cucumber will look for",
              "foo/bar_zap.rb. You can place the file with this relative",
              "path underneath your features/support directory or anywhere",
              "on Ruby's LOAD_PATH, for example in a Ruby gem."
      ]

      OPTIONS_WITH_ARGS << ['--report_to']

    end
  end
end
