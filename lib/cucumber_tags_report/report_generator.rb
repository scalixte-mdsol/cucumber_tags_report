require 'multi_json'
require 'base64'
require 'cucumber/formatter/io'
module CucumberTagsReport
  class ReportGenerator
    attr_reader :file
    include Cucumber::Formatter::Io

    def initialize(file_io)
      puts "------------"
      puts file_io
      puts "------------"
      @file = ensure_io(file_io, "csv_generator")
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
