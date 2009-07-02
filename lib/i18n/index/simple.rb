require 'i18n/index/simple/building'
require 'i18n/index/simple/storage'
require 'i18n/index/simple/data'
require 'i18n/index/simple/formatter'

module I18n
  module Index
    class Simple
      include Building
      include Storage

      attr_accessor :root_dir, :pattern

      def initialize(options = {})
        self.root_dir = options[:root_dir] || Dir.pwd
        self.pattern = options[:pattern] || Index.default_pattern

        options[:formatter].setup(self) if options[:formatter]
      end

      def data
        @data ||= Data.new
        build unless built?
        @data
      end
      
      def keys
        @data.keys
      end
      
      def occurences
        @data.values.map { |value| value[:occurences] }.flatten
      end

    	def find_call(*keys)
    		return unless key = data.keys.detect { |key, data| key.matches?(*keys) }
    		occurence = data.occurences(key).first
    		occurence.code.select(Ruby::Call, :position => occurence.position).first
    	end

      def replace_key(call, search, replacement)
        data.remove(call)
        call.replace_key(search.to_s.gsub(/[^\w\.]/, ''), replacement.to_sym)
        data.add(call)
        save if built?
      end
  	end
  end
end