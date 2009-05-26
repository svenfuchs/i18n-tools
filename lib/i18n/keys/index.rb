require 'yaml'
require File.dirname(__FILE__) + '/formatter'
require File.dirname(__FILE__) + '/occurence'

# Keys.index(:default, :pattern => '/**/*.{rb,erb}').each(:foo, :bar) { |occurence| ... }
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

      class << self
        def load_or_create_or_init(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          name = TrueClass === args.first ? :default : args.first
          index = name ? load_or_create(name, options) : new(name, options)
          index
        end

        def load_or_create(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          name = args.first || :default
          exists?(name) ? load(name) : create(name, options)
        end

        def create(*args)
          index = new(*args)
          index.update
          index
        end

        def load(name)
          File.open(filename(name), 'r') { |f| Marshal.load(f) } if exists?
        end

        def mk_dir
          FileUtils.mkdir_p(store_dir) unless exists?
        end

        def exists?(name = nil)
          name ? File.exists?(filename(name)) : File.exists?(store_dir)
        end

        def delete(name)
          new(name).delete
        end

        def delete_all
          FileUtils.rm_r(store_dir) if exists? rescue Errno::ENOENT
        end

        def filename(name)
          store_dir + "/#{name.to_s}.marshal"
        end

        def store_dir
          File.expand_path(Keys.meta_dir + '/indizes')
        end
      end

      attr_reader :name

      [:keys, :occurences, :by_key].each do |name|
        class_eval <<-code
          def #{name}             # def key
            build unless built?   #   build unless built?
            @#{name}              #   @key
          end                     # end
        code
      end

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        @name = args.first || :default
        @pattern = options[:pattern] || @@default_pattern
        reset!
        @@formatter.setup(self) if @@formatter
      end

      def reset!
        @built = false
        @keys = []
        @occurences = []
        @by_key = {}
      end

      def built?
        @built
      end

      def build(options = {})
        @occurences = find_occurences(options)
        @occurences.each do |occurence|
          @keys << occurence.key
          (@by_key[occurence.key] ||= []) << occurence
        end
        @built = true
      end

      def exists?
        File.exists?(filename)
      end

      def save
        self.class.mk_dir
        File.open(filename, 'w+') { |f| Marshal.dump(self, f) }
      end

      def update(options = {})
        reset!
        build(options)
        save
      end

      def delete
        FileUtils.rm(filename) if exists? rescue Errno::ENOENT
      end

      def filename
        self.class.filename(name)
      end

      def files
        Dir[Keys.root + pattern]
      end

      def pattern
        @pattern ||= config['pattern'] || @@default_pattern
      end

      def config
        @config ||= Keys.config['indices'][name] || { }
      end
      
      def each(*keys)
        patterns = key_patterns(keys)
        occurences.each { |occurence| yield(occurence) if key_matches?(occurence.key, patterns) }
      end
      
      def inject(memo, *keys)
        each(*keys) { |occurence| yield(memo, occurence) }
        memo
      end
      
      def replace!(occurence, replacement)
        occurence.replace!(replacement)
        save if exists?
      end

      def marshal_dump
        keys = :name, :pattern, :keys, :occurences, :by_key
        keys.inject({ :built => built? }) { |result, key| result[key] = send(key); result }
      end

      def marshal_load(data)
        keys = :name, :pattern, :keys, :occurences, :by_key, :built
        keys.each { |key| instance_variable_set(:"@#{key}", data[key]) }
      end

      protected
      
        def find_occurences(options)
          files.inject([]) do |result, file|
            code = parse(file) || Sexp.new
            code.find_by_type(:call).select { |call| call[2] == :t }.inject(result) do |result, node|
              node.each_key_node { |key| result << Occurence.from_sexp(key, file) }
              result
            end
          end
        end
        
        def key_matches?(subject, key_patterns)
          key_patterns.empty? || key_patterns.any? do |key, pattern| 
            subject.to_sym == key || subject.to_s =~ pattern
          end
        end
        
        def key_patterns(keys)
          keys.inject({}) { |result, key| result[key] = key_pattern(key); result }
        end
        
        def key_pattern(key)
          key = key.to_s.dup
          match_end = key.gsub!(/\*$/, '') ? '' : '$'
          pattern = Regexp.escape("#{key}")
          /^#{pattern}#{match_end}/
        end

        def parse(file)
          source = File.read(file)
          source = ErbParser.new.to_ruby(source) if File.extname(file) == '.erb'
          RubyParser.new.parse(source)
        end
    end
  end
end