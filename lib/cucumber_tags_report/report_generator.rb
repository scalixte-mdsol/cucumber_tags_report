require 'multi_json'
require 'base64'
require 'csv'
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
      puts file_io.split
      puts "------------"
      ensure
      @file = ensure_io('file.csv', "csv_generator")
    end

    def generate_report(report_hash)
      # CSV.open("data.csv", "w", headers: hashes.first.keys) do |csv|
      #   hashes.each do |h|
      #     # csv << h.values
      #     CSV::Writer.generate(outfile) do |csv|
      #       csv << ['c1', nil, '', '"', "\r\n", 'c2']
      #     end
      #   end
      # end
      CSV::Writer.generate(@file) do |csv|
        csv << report_hash.first.keys
        report_hash.each do |hash|
          csv << hash.values
        end
      end
    end
  end
end
