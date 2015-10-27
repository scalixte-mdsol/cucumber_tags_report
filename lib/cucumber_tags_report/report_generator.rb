require 'multi_json'
require 'base64'
require 'csv'
# require 'fastercsv'
require 'cucumber/formatter/io'

module CucumberTagsReport
  class ReportGenerator
    attr_reader :file
    include Cucumber::Formatter::Io

    def initialize(file_io)
      puts "------------"
      puts file_io.respond_to?(:to_i)
      puts file_io.respond_to?(:to_s)
      puts file_io.respond_to?(:to_hash)
      puts file_io.respond_to?(:to_a)
      puts file_io.class
      puts file_io.count
      puts file_io[0]
      puts file_io.split[1]
      puts "------------"
      ensure
      # @file = ensure_io('file.csv', "csv_generator")
    end

    def generate_report(report_hash)
      CSV.open("file.csv", "w") do |csv|
        csv << report_hash.first.keys
        report_hash.each do |hash|
          csv << hash.values
        end
      end
      # end
      # FasterCSV.generate(@file) do |csv|
      #   csv << report_hash.first.keys
      #   report_hash.each do |hash|
      #     csv << hash.values
      #   end
      # end
    end
  end
end
