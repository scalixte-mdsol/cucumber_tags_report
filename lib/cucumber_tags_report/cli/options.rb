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

      # def parse!(args)
      #   @args = args
      #   @expanded_args = @args.dup
      #
      #   @args.extend(::OptionParser::Arguable)
      #
      #   @args.options do |opts|
      #     opts.on_tail("--report_to", "You're looking at it.") do
      #       # @out_stream.puts opts.help
      #       # Kernel.exit(0)
      #     end
      #   end.parse
      #
      #   super
      # end

      def parse!(args)
        @args = args
        @expanded_args = @args.dup

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Usage: cucumber [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]+", "",
                         "Examples:",
                         "cucumber examples/i18n/en/features",
                         "cucumber @rerun.txt (See --format rerun)",
                         "cucumber examples/i18n/it/features/somma.feature:6:98:113",
                         "cucumber -s -i http://rubyurl.com/eeCl", "", "",
          ].join("\n")
          opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR",
                  "Require files before executing the features. If this",
                  "option is not specified, all *.rb files that are",
                  "siblings or below the features will be loaded auto-",
                  "matically. Automatic loading is disabled when this",
                  "option is specified, and all loading becomes explicit.",
                  "Files under directories named \"support\" are always",
                  "loaded first.",
                  "This option can be specified multiple times.") do |v|
            @options[:require] << v
            if(Cucumber::JRUBY && File.directory?(v))
              require 'java'
              $CLASSPATH << v
            end
          end

          if(Cucumber::JRUBY)
            opts.on("-j DIR", "--jars DIR",
                    "Load all the jars under DIR") do |jars|
              Dir["#{jars}/**/*.jar"].each {|jar| require jar}
            end
          end

          opts.on("--i18n LANG",
                  "List keywords for in a particular language",
                  %{Run with "--i18n help" to see all languages}) do |lang|
            if lang == 'help'
              list_languages_and_exit
            else
              list_keywords_and_exit(lang)
            end
          end
          opts.on("-f FORMAT", "--format FORMAT",
                  "How to format features (Default: pretty). Available formats:",
                  *FORMAT_HELP) do |v|
            @options[:formats] << [v, @out_stream]
          end
          opts.on("-o", "--out [FILE|DIR]",
                  "Write output to a file/directory instead of STDOUT. This option",
                  "applies to the previously specified --format, or the",
                  "default format if no format is specified. Check the specific",
                  "formatter's docs to see whether to pass a file or a dir.") do |v|
            @options[:formats] << ['pretty', nil] if @options[:formats].empty?
            @options[:formats][-1][1] = v
          end
          opts.on("-t TAG_EXPRESSION", "--tags TAG_EXPRESSION",
                  "Only execute the features or scenarios with tags matching TAG_EXPRESSION.",
                  "Scenarios inherit tags declared on the Feature level. The simplest",
                  "TAG_EXPRESSION is simply a tag. Example: --tags @dev. When a tag in a tag",
                  "expression starts with a ~, this represents boolean NOT. Example: --tags ~@dev.",
                  "A tag expression can have several tags separated by a comma, which represents",
                  "logical OR. Example: --tags @dev,@wip. The --tags option can be specified",
                  "several times, and this represents logical AND. Example: --tags @foo,~@bar --tags @zap.",
                  "This represents the boolean expression (@foo || !@bar) && @zap.",
                  "\n",
                  "Beware that if you want to use several negative tags to exclude several tags",
                  "you have to use logical AND: --tags ~@fixme --tags ~@buggy.",
                  "\n",
                  "Positive tags can be given a threshold to limit the number of occurrences.",
                  "Example: --tags @qa:3 will fail if there are more than 3 occurrences of the @qa tag.",
                  "This can be practical if you are practicing Kanban or CONWIP.") do |v|
            @options[:tag_expressions] << v
          end
          opts.on("-n NAME", "--name NAME",
                  "Only execute the feature elements which match part of the given name.",
                  "If this option is given more than once, it will match against all the",
                  "given names.") do |v|
            @options[:name_regexps] << /#{v}/
          end
          opts.on("-e", "--exclude PATTERN", "Don't run feature files or require ruby files matching PATTERN") do |v|
            @options[:excludes] << Regexp.new(v)
          end
          opts.on(PROFILE_SHORT_FLAG, "#{PROFILE_LONG_FLAG} PROFILE",
                  "Pull commandline arguments from cucumber.yml which can be defined as",
                  "strings or arrays.  When a 'default' profile is defined and no profile",
                  "is specified it is always used. (Unless disabled, see -P below.)",
                  "When feature files are defined in a profile and on the command line",
                  "then only the ones from the command line are used.") do |v|
            @profiles << v
          end
          opts.on(NO_PROFILE_SHORT_FLAG, NO_PROFILE_LONG_FLAG,
                  "Disables all profile loading to avoid using the 'default' profile.") do |v|
            @disable_profile_loading = true
          end
          opts.on("-c", "--[no-]color",
                  "Whether or not to use ANSI color in the output. Cucumber decides",
                  "based on your platform and the output destination if not specified.") do |v|
            Cucumber::Term::ANSIColor.coloring = v
          end
          opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.",
                  "This also omits the loading of your support/env.rb file if it exists.") do
            @options[:dry_run] = true
          end
          opts.on("-a", "--autoformat DIR",
                  "Reformats (pretty prints) feature files and write them to DIRECTORY.",
                  "Be careful if you choose to overwrite the originals.",
                  "Implies --dry-run --format pretty.") do |directory|
            @options[:autoformat] = directory
            Cucumber::Term::ANSIColor.coloring = false
            @options[:dry_run] = true
            @quiet = true
          end

          opts.on("--report_to",
                  "Whether or not to use ANSI color in the output. Cucumber decides",
                  "based on your platform and the output destination if not specified.") do |v|
            @out_stream.puts v
          end

          opts.on("-m", "--no-multiline",
                  "Don't print multiline strings and tables under steps.") do
            @options[:no_multiline] = true
          end
          opts.on("-s", "--no-source",
                  "Don't print the file and line of the step definition with the steps.") do
            @options[:source] = false
          end
          opts.on("-i", "--no-snippets", "Don't print snippets for pending steps.") do
            @options[:snippets] = false
          end
          opts.on("-I", "--snippet-type TYPE",
                  "Use different snippet type (Default: regexp). Available types:",
                  *Cucumber::RbSupport::RbLanguage.cli_snippet_type_options) do |v|
            @options[:snippet_type] = v.to_sym
          end

          opts.on("-q", "--quiet", "Alias for --no-snippets --no-source.") do
            @quiet = true
          end
          opts.on("-b", "--backtrace", "Show full backtrace for all errors.") do
            Cucumber.use_full_backtrace = true
          end
          opts.on("-S", "--strict", "Fail if there are any undefined or pending steps.") do
            @options[:strict] = true
          end
          opts.on("-w", "--wip", "Fail if there are any passing scenarios.") do
            @options[:wip] = true
          end
          opts.on("-v", "--verbose", "Show the files and features loaded.") do
            @options[:verbose] = true
          end
          opts.on("-g", "--guess", "Guess best match for Ambiguous steps.") do
            @options[:guess] = true
          end
          opts.on("-l", "--lines LINES", "Run given line numbers. Equivalent to FILE:LINE syntax") do |lines|
            @options[:lines] = lines
          end
          opts.on("-x", "--expand", "Expand Scenario Outline Tables in output.") do
            @options[:expand] = true
          end
          opts.on(DRB_OPTIONAL_FLAG, "Run features against a DRb server. (i.e. with the spork gem)") do |drb|
            @options[:drb] = drb
          end
          opts.on("--port PORT", "Specify DRb port.  Ignored without --drb") do |port|
            @options[:drb_port] = port
          end
          opts.on("--dotcucumber DIR", "Write metadata to DIR") do |dir|
            @options[:dotcucumber] = dir
          end
          opts.on_tail("--version", "Show version.") do
            @out_stream.puts Cucumber::VERSION
            Kernel.exit(0)
          end
          opts.on_tail("-h", "--help", "You're looking at it.") do
            @out_stream.puts opts.help
            Kernel.exit(0)
          end
        end.parse!

        if @quiet
          @options[:snippets] = @options[:source] = false
        else
          @options[:snippets] = true if @options[:snippets].nil?
          @options[:source]   = true if @options[:source].nil?
        end
        @args.map! { |a| "#{a}:#{@options[:lines]}" } if @options[:lines]

        extract_environment_variables
        @options[:paths] = @args.dup #whatver is left over

        merge_profiles

        self
      end
    end
  end
end
