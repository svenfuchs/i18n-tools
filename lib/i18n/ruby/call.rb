require 'core_ext/object/meta_class'

module Ruby
  class Call
    def to_translate_call
      meta_class.send(:include, TranslateCall)
      arguments.to_translate_args_list
      self
      # TranslateCall.new(target, self, arguments.to_translate_args_list).tap { |c| c.parent = parent }
    end
  end

  class ArgsList
    def to_translate_args_list
      meta_class.send(:include, TranslateArgsList)
      self
      # TranslateArgsList.new(args, parentheses).tap { |a| a.parent = parent }
    end
  end
end
