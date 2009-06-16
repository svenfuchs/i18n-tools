require 'i18n/keys/index/formatter'
require 'i18n/keys/index/store'
require 'i18n/ripper/ruby_builder'

# Index.new(project, :default, :pattern => '/**/*.{rb,erb}').each(:foo, :bar) { |call| ... }
#
# when the :index name is not given it creates the index on the fly but won't save it
# when the :index name is true it uses :default as an index name
#
# when an index with the given name does not exist it builds and saves an index
# when an index with the given name exists and the given pattern does not match
#   the index's pattern it issues a warning and rebuilds the index
#
# when no keys are given, occurences of all keys will be iterated
# when keys are given, only occurences of the given keys will be iterated

module I18n
  module Keys
    class Index
      include Enumerable

      @@formatter = Formatter::Stdin
      @@default_pattern = '/**/*.{rb,erb}'
      @@default_parser = I18n::Ripper::RubyBuilder

      attr_accessor :project, :name, :parser, :pattern

      [:keys, :calls, :by_key].each do |name|
        class_eval <<-code
          def #{name}             # def key
            build unless built?   #   build unless built?
            @#{name}              #   @key
          end                     # end
        code
      end

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        self.project = args.shift
        self.name = args.shift || :default

        self.pattern = options[:pattern] || @@default_pattern
        self.parser = options[:parser] || @@default_parser

        reset!
        @@formatter.setup(self) if @@formatter
      end

      def reset!
        @built = false
        @keys = []
        @calls = []
        @by_key = {}
      end

      def built?
        @built
      end

      def build
        @calls = find_calls
        @calls.each do |call|
          key = call.full_key(true) #.map { |key| key.to_s }.join('.').to_sym
          @keys << key unless @keys.include?(key)
          (@by_key[key] ||= []) << call # uh, Argument.hash doesn't seem to work??
        end
        @built = true
      end

      def exists?
        File.exists?(filename)
      end

      def save
        project.indices.mk_dir
        File.open(filename, 'w+') { |f| Marshal.dump(self, f) }
      end

      def update
        reset!
        build
        save
      end

      def delete
        FileUtils.rm(filename) if exists? rescue Errno::ENOENT
      end

      def filename
        project.indices.filename(name)
      end

      def files
        Dir[project.root_dir + pattern]
      end

      def pattern
        @pattern ||= config['pattern'] || @@default_pattern
      end

      def config
        @config ||= project.config['indices'][name] || { }
      end

      def each(*keys)
        patterns = key_patterns(keys)
        calls.each { |call| yield(call) if key_matches?(call.full_key(true), patterns) }
      end

      def inject(memo, *keys)
        each(*keys) { |call| yield(memo, call) }
        memo
      end

      def replace_key(call, search, replacement)
        search = search.to_s.gsub(/[^\w\.]/, '')
        replacement = replacement.to_sym

        # TODO update @keys as well or remove it
        key = call.full_key(true)
        @by_key[key].delete(call) if @by_key[key]
        @by_key.delete(key) if @by_key[key].empty?

        call.replace_key(search, replacement)

        key = call.full_key(true)
        @by_key[key] ||= []
        @by_key[key] << call

        save if built?
      end

      def marshal_dump
        keys = :name, :pattern, :keys, :calls, :by_key
        keys.inject({ :built => built? }) { |result, key| result[key] = send(key); result }
      end

      def marshal_load(data)
        keys = :name, :pattern, :keys, :calls, :by_key, :built
        keys.each { |key| instance_variable_set(:"@#{key}", data[key]) }
      end

      protected

        def find_calls
          files.inject([]) do |result, file|
            result += parse(file).translate_calls
          end
        end

        def parse(file)
          source = File.read(file)
          parser.new(source, file).tap { |parser| parser.parse }
        end

        def key_matches?(subject, key_patterns)
          key_patterns.empty? || key_patterns.any? do |key, pattern|
            # p "#{subject.to_s} #{pattern.inspect}"
            subject.to_sym == key || subject.to_s =~ pattern
          end
        end

        def key_patterns(keys)
          keys.inject({}) { |result, key| result[key] = key_pattern(key); result }
        end

        def key_pattern(key)
          key = key.to_s.dup
          match_start = key.gsub!(/^\*/, '') ? '' : '^'
          match_end = key.gsub!(/\*$/, '') ? '' : '$'
          pattern = Regexp.escape("#{key}")
          /#{match_start}#{pattern}#{match_end}/
        end
    end
  end
end