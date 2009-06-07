module Ruby
  class Call
    def to_translate_call
      TranslateCall.new(target, self, arguments.to_translate_args_list).tap { |c| c.parent = parent }
    end
  end

  class ArgsList
    def to_translate_args_list
      TranslateArgsList.new(args, parentheses).tap { |a| a.parent = parent }
    end
  end
end