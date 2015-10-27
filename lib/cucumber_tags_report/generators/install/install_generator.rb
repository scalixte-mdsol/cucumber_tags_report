begin
  if defined? Rails
    require 'rails/generators'
    require 'rails/generators/base'
  end
rescue
  loadError
end

module CucumberTagsReport
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc 'Add new configuration to cucumber'

      class_option :autogenerate, :type => :boolean, :default => false, :desc => "Auto generate data content for formatter."
      def create_install
        empty_directory 'features/support'
        template '../templates/tags_list_formatter.yml', File.join('features/support/', "tags_list_formatter.yml")
      end

    end
  end
end

