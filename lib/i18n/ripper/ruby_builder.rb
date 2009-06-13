require 'ripper/ruby_builder'
require 'i18n/ripper/collectors/translate_calls'

module I18n
  module Ripper
    class RubyBuilder < ::Ripper::RubyBuilder
      include Collectors::TranslateCalls
    end
  end
end

