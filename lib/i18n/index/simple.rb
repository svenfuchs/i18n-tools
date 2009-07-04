require 'i18n/base'
require 'i18n/index/key'
require 'i18n/index/occurence'
require 'i18n/index/format'
require 'i18n/index/simple/storage'
require 'i18n/index/simple/data'
require 'erb/stripper'

module I18n
  module Index
    class Simple < Base
      include Storage

    	def find_call(*keys)
    		return unless key = data.keys.detect { |key, data| key.matches?(*keys) }
    		occurence = data.occurences(key).first
    		# TODO cache parsed files on Index
    		files[occurence.filename].ruby.select(Ruby::Call, :position => occurence.position).first
    	end

    	def find_calls(*keys)
    		keys = data.keys.select { |key, data| key.matches?(*keys) }
    		occurences = keys.map { |key| data.occurences(key) }.flatten
    		occurences.map do |occurence|
    		  files[occurence.filename].ruby.select(Ruby::Call, :position => occurence.position)
  		  end.flatten
    	end

      def replace_key(call, search, replacement)
        data.remove(call)
        call.replace_key(search.to_s.gsub(/[^\w\.]/, ''), replacement.to_sym)
        files[call.filename].update(call.root.src)
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
          calls = filenames.map { |filename| files[filename].calls }.flatten
          calls.each { |call| data.add(call) }
        end
  	end
  end
end