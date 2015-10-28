require 'multi_json'
require 'base64'
require 'csv'
require 'cucumber/formatter/io'

module CucumberTagsReport
  class ReportGenerator
    attr_reader :file, :generator
    include Cucumber::Formatter::Io

    def initialize(file_io)
      # @file = ensure_exists(file_io.split[1])
      @file=file.csv
      load_generator if @file
    end

    def generate_report(report_hash)
      if @generator
        load_complete_report(report_hash)
      else
        load_basic_report(report_hash)
      end

    end

    private

    def ensure_exists(file)
      return nil if file.nil?
      raise "unable to process file" unless File.exists?(file)
      return file
    end

    def load_generator
      begin
        require 'yaml'
        if (File.exist?(file='features/support/tags_list_formatter.yml'))
          @generator=YAML.load(File.open(file))
        else
          @generator=nil
        end
      rescue
        @generator=nil
        puts 'could not load content'
      end
    end

    def load_basic_report(report_hash)
      CSV.open(@file, "w") do |csv|
        csv << report_hash.first.keys
        report_hash.each do |hash|
          csv << hash.values
        end
      end
    end

    def load_complete_report(report_hash)
      headers=[]
      @generator.keys.each do |key|
        headers << @generator[key].keys rescue nil
      end
      headers.flatten!

      CSV.open(@file, "w") do |csv|
        csv << headers
        report_hash.each do |hash|
          row = []
          @generator.keys.each do |key|
            case key
              when /Headers/
                @generator[key].each do |k,v|
                  row.push(hash[v])
                end
              when /Show Tags/
                @generator[key].each do |k,v|
                  row.push(hash[:tags].detect{|value| value =~ /#{v}/})
                end
              when /Tags/
                @generator[key].each do |k,v|
                  row.push(hash[:tags].any?{|value| value =~ /#{v}/} ? "Yes" : "No")
                end
            end
          end
          csv << row
        end
      end
    end

  end
end
