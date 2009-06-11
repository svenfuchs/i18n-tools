require 'ruby/call'
require 'i18n/ruby/call'
require 'i18n/ruby/translate_args_list'

module Ruby
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
    
    def replace_key!(search, replacement)
      arguments.replace_key!(search, replacement)
    end
  end
end