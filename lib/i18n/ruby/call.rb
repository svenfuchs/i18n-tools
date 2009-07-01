require 'core_ext/object/meta_class'

module Ruby
  class Call
    def to_translate_call
      meta_class.send(:include, TranslateCall)
      arguments.to_translate_args_list if arguments.respond_to?(:to_translate_args_list)
      self
    end
  end

  class ArgsList
    def to_translate_args_list
      meta_class.send(:include, TranslateArgsList)
      self
    end
  end
end
