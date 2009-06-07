require 'i18n/ruby/translate_call'

module I18n
  module Ripper
    module Collectors
      module TranslateCalls
        [:on_method_add_arg].each do |method|
          self.class_eval <<-eoc
            def #{method}(*args)
              call = super
              collect_translate_call(call.to_translate_call) or call
            end
          eoc
        end
      
        def translate_calls
          @translate_calls ||= []
        end
      
        def collect_translate_call(call)
          call.tap { |c| translate_calls << c } if is_translate_call?(call)
        end
      
        KEY_CLASSES = [Ruby::Symbol, Ruby::DynaSymbol, Ruby::String, Ruby::Array]
      
        def is_translate_call?(call)
          call.token == 't' &&
          (!call.target.respond_to?(:token) or call.target.token == 'I18n') && 
          KEY_CLASSES.include?(call.arguments.first.class)
        end
      end
    end
  end
end