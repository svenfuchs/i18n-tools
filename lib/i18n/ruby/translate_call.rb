require 'ruby/call'
require 'i18n/ruby/call'
require 'i18n/ruby/translate_args_list'

module Ruby
  module TranslateCall
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
    
    def replace_key!(search, replacement)
      arguments.replace_key!(search, replacement)
    end
  end
end