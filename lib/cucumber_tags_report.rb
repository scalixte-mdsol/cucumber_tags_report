module CucumberTagsReport
  require_relative 'cucumber_tags_report/version'
  require_relative 'cucumber_tags_report/report_generator'
  require_relative 'cucumber_tags_report/formatter/tags_list'
  require_relative 'cucumber_tags_report/formatter/tags_report'
  require_relative 'cucumber_tags_report/generators/cucumber_tags_report/install/install_generator' # if defined? Rails
  # require_relative 'cucumber_tags_report/cli/options'
  # require_relative 'cucumber_tags_report/cli/configuration'
  # require_relative 'cucumber_tags_report/cli/main'
end
