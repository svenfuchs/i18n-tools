module I18n
  module Ripper
    class RubyBuilder < ::Ripper::RubyBuilder
      def on_stmts_add(target, statement)
        super.tap do
          collect_translate_call(statement.to_translate_call) if statement.is_a?(Ruby::Call)
        end
      end
    
      def translate_calls
        @translate_calls ||= []
      end
    
      def collect_translate_call(call)
        call.tap { |c| translate_calls << c } if is_translate_call?(call)
      end
    
      KEY_CLASSES = [Ruby::Symbol, Ruby::DynaSymbol, Ruby::String, Ruby::Array]
    
      def is_translate_call?(call)
        call.identifier.try(:token) == 't' &&
        (!call.target.respond_to?(:token) || call.target.token == 'I18n') && 
        call.arguments && KEY_CLASSES.include?(call.arguments.first.arg.class)
      end
    end
  end
end
