require 'multi_json'
require 'base64'
require 'csv'
# require 'fastercsv'
require 'cucumber/formatter/io'

module CucumberTagsReport
  class ReportGenerator
    attr_reader :file, :generator
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
      load_generator
      # @file = ensure_io('file.csv', "csv_generator")
    end

    def generate_report(report_hash)
      dir = File.expand_path(File.dirname(__FILE__))
      puts dir
      puts @generator

      if @generator
        load_complete_report(report_hash)
      else
        load_basic_report(report_hash)
      end

    end

    private

    def load_generator
      begin
        require 'yaml'
        if (File.exist?(file='features/support/tags_list_formatter.yml'))
          @generator=YAML.load(File.open(file))
        else
          @generator=YAML.load(File.open(File.join(File.dirname(__FILE__), 'generators', 'templates', 'tags_list_formatter.yml')))
        end
      rescue
        @generator=nil
        puts Dir.exist?(File.join(File.dirname(__FILE__), 'generators', 'templates'))
        puts Dir.exist?(File.join(File.dirname(__FILE__), 'generators'))
        puts Dir.exist?(File.join(File.dirname(__FILE__)))
        puts File.exists?(File.join(File.dirname(__FILE__), 'generators', 'templates', 'tags_list_formatter.yml'))
        puts 'could not load content'
      end
    end

    def load_basic_report(report_hash)
      CSV.open("file.csv", "w") do |csv|
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

      CSV.open("file.csv", "w") do |csv|
        csv << headers
        report_hash.each do |hash|
          puts hash
          row = []
          @generator.keys.each do |key|
            case key
              when /Headers/
                @generator[key].each do |k,v|
                  row.push(hash[v])
                end
              when /Show Tags/
                @generator[key].each do |k,v|
                  puts v
                  row.push(hash[:tags].detect{|value| value =~ Regexp.new(v)})
                end
              when /Tags/
                @generator[key].each do |k,v|
                  row.push(hash[:tags].any?{|value| value =~ Regexp.new(v)} ? "Yes" : "No")
                end
            end
          end
          csv << row
        end
      end
    end

  end
end
