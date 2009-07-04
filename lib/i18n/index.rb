require 'core_ext/module/attribute_accessors'

require 'i18n/index/file'
require 'i18n/index/simple'
require 'i18n/ripper2ruby'

module I18n
  module Index
    mattr_accessor :default_pattern, :implementation, :parser, :filters

    @@implementation  = I18n::Index::Simple
    @@parser          = I18n::Ripper::RubyBuilder
    @@filters         = { :erb => lambda { |source| Erb::Stripper.new.to_ruby(source) } }
    @@pattern         = '**/*.{rb,erb}'

    class << self
      def new(*args)
        implementation.new(*args)
      end

      def load_or_create(*args)
        implementation.load_or_create(*args)
      end

      def filter(source, filename)
        filters.each do |extname, filter|
          source = filter.call(source) if ::File.extname(filename)[1, -1] == extname.to_s
        end
        source
      end
    end
  end
end
