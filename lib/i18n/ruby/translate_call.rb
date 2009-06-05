require 'ruby/call'
require 'i18n/ruby/call'
require 'i18n/ruby/translate_args_list'

module Ruby
  class TranslateCall < Call
    def full_key
      arguments.full_key
    end
    
    def key
      arguments.key
    end
    
    def scope
      arguments.scope
    end
    
    def key_matches?(keys)
      arguments.key_matches?(keys)
    end
  end
end