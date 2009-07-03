require 'i18n/exceptions'
require 'i18n/index/simple'
require 'i18n/index/key'
require 'i18n/index/occurence'
require 'i18n/index/format'
require 'i18n/ripper2ruby'

module I18n
  module Index
    @@implementation = I18n::Index::Simple
    @@parser = I18n::Ripper::RubyBuilder
    @@default_pattern = '**/*.{rb,erb}'
  
    class << self
      def implementation
        @@implementation
      end

      def implementation=(implementation)
        @@implementation = implementation
      end
      
      def parser
        @@parser
      end

      def parser=(parser)
        @@parser = parser
      end
    
      def default_pattern
        @@default_pattern
      end

      def default_pattern=(default_pattern)
        @@default_pattern = default_pattern
      end
      
      def new(*args)
        @@implementation.new(*args)
      end
      
      def load_or_create(*args)
        @@implementation.load_or_create(*args)
      end
    end
  end
end
