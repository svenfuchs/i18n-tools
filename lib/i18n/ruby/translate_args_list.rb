require 'ruby/call'
require 'i18n/ruby/call'

module Ruby
  # class TranslateArgsList < ArgsList
  module TranslateArgsList
    def full_key
      normalize_keys(key, scope)
    end
    
    def key
      eval(first.to_ruby) if first
    end
    
    def scope
      last.is_a?(Ruby::Hash) ? last.value[:scope] : nil
    end
    
    def key_matches?(keys)
      keys = normalize_keys(keys)
      keys == full_key[0, keys.length]
    end
    
    def replace_key!(search, replacement)
      key, scope = compute_key_replacement(search, replacement)
      original_length = length

      first.token = key.map { |k| k.to_s }.join('.')
      update_options(:scope, scope) # TODO fix positions!

      root.replace_src(row, column, original_length, to_ruby)
    end
    
    protected
    
      def compute_key_replacement(search, replacement)
        key = normalize_keys(self.key)
        scope = normalize_keys(nil, self.scope)
      
        scope = self.full_key
        scope[0, search.length] = replacement
        key = scope.slice!(-key.length, key.length) # i.e. we preserve the key length?
        scope = nil if scope.empty?
      
        [key, scope]
      end
    
      def normalize_keys(key, scope = nil)
        I18n.send(:normalize_translation_keys, nil, key, scope)
      end
  end
end

unless defined?(I18n) && I18n.respond_to?(:normalize_translation_keys) # should be required, eh?
  module I18n
    def self.normalize_translation_keys(locale, key, scope)
      keys = [locale] + Array(scope) + [key]
      keys = keys.map { |k| k.to_s.split(/\./) }
      keys.flatten.map { |k| k.to_sym }
    end
  end
end