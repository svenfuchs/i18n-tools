require 'i18n/index/simple/storage'
require 'i18n/index/simple/data'

module I18n
  module Index
    class Simple
      include Storage

      attr_accessor :root_dir, :pattern

      def initialize(options = {})
        self.root_dir = options[:root_dir] || Dir.pwd
        self.pattern = options[:pattern] || Index.default_pattern

        options[:format].setup(self) if options[:format]
      end
      
    	def find_call(*keys)
    		return unless key = data.keys.detect { |key, data| key.matches?(*keys) }
    		occurence = data.occurences(key).first
    		occurence.code.select(Ruby::Call, :position => occurence.position).first
    	end

    	def find_calls(*keys)
    		keys = data.keys.select { |key, data| key.matches?(*keys) }
    		occurences = keys.map { |key| data.occurences(key) }.flatten
    		occurences.map { |occurence| occurence.code.select(Ruby::Call, :position => occurence.position) }.flatten
    	end

      def replace_key(call, search, replacement)
        data.remove(call)
        call.replace_key(search.to_s.gsub(/[^\w\.]/, ''), replacement.to_sym)
        data.add(call)
        save if built?
      end
      
      def data
        @data ||= Data.new
        build unless built?
        @data
      end
      
      def keys
        data.keys
      end
      
      def occurences
        data.values.map { |value| value[:occurences] }.flatten
      end

      def files
        Dir[root_dir + '/' + pattern]
      end

      protected
      
        def reset!
          @built = false
          @data = nil
        end
    
        def built?
          @built
        end

        def build
          reset!
          @built = true
          calls = files.inject([]) { |result, file| result += parse(file).translate_calls }
          calls.each { |call| data.add(call) }
        end

        def parse(file)
          source = File.read(file)
          source = Erb::Stripper.new.to_ruby(source) if File.extname(file) == '.erb'
          Index.parser.new(source, file).tap { |p| p.parse }
        end
  	end
  end
end