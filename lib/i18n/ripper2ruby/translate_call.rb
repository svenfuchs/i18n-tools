module Ruby
  class Call
    def to_translate_call
      meta_class.send(:include, TranslateCall)
      arguments.to_translate_args_list if arguments.respond_to?(:to_translate_args_list)
      self
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
      "#{key}: #{filename} [#{row}/#{column}]\n" +
      (options.has_key?(:context) ? self.context(options.update(:width => options[:context].to_i)) : '')
    end
  end
end