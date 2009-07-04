module Ruby
  class Node
    def select_translate_calls(*args)
      select(Ruby::Call, *args) { |node| node.is_translate_call? }.map { |call| call.to_translate_call }
    end

    def is_translate_call?
      false
    end
  end

  class Call
    def to_translate_call
      unless meta_class.include?(TranslateCall)
        meta_class.send(:include, TranslateCall)
        arguments.to_translate_args_list if arguments.respond_to?(:to_translate_args_list)
      end
      self
    end

    def is_translate_call?
      identifier.try(:token) == 't' &&
      is_translate_method_target?(target) &&
      is_translate_key?(arguments.first.try(:arg))
    end
    
    protected

      def is_translate_method_target?(target)
        target.nil? || target.try(:identifier).try(:token) == 'I18n'
      end

      def is_translate_key?(arg)
        # TODO ... what to do with Arrays? what to do with DynaSymbols w/ embedded expressions?
        arg && [Ruby::Symbol, Ruby::DynaSymbol, Ruby::String].include?(arg.class) && arg.try(:value)
      end
  end

  module TranslateCall
    def full_key(*args)
      arguments.full_key(*args)
    end

    def key(*args)
      arguments.key(*args)
    end

    def scope(*args)
      arguments.scope(*args)
    end

    def key_matches?(*args)
      arguments.key_matches?(*args)
    end

    def replace_key(search, replacement)
      arguments.replace_key(search, replacement)
    end

    def to_s(options = {})
      context = (options.has_key?(:context) ? self.context(options.update(:width => options[:context].to_i)) : '')
      context = context.split("\n").map(&:strip).join("\n")
      "#{key}: #{filename} [#{row}/#{column}]\n" + context
    end
  end
end