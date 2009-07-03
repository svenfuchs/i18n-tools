require 'i18n/index/simple/storage'
require 'i18n/index/simple/data'
require 'erb/stripper'

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
    		# TODO cache parsed files on Index
    		Index.ruby(occurence.filename).select(Ruby::Call, :position => occurence.position).first
    	end

    	def find_calls(*keys)
    		keys = data.keys.select { |key, data| key.matches?(*keys) }
    		occurences = keys.map { |key| data.occurences(key) }.flatten
    		occurences.map do |occurence|
    		  Index.ruby(occurence.filename).select(Ruby::Call, :position => occurence.position)
  		  end.flatten
    	end

      def replace_key(call, search, replacement)
        data.remove(call)
        call.replace_key(search.to_s.gsub(/[^\w\.]/, ''), replacement.to_sym)
        save_source(call.filename, call.root.src)
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

      def filenames
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
          calls = filenames.map { |filename| Index.calls(filename) }.flatten
          calls.each { |call| data.add(call) }
        end

        def save_source(filename, data)
          files = Index.files(filename)
          files.data = data
          files.save
        end
  	end
  end
end