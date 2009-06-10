require 'ruby/call'
require 'i18n/ruby/call'

module Ruby
  module TranslateArgsList
    def full_key
      normalize_keys(scope, key)
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
      key, scope = compute_replacement_keys(search, replacement)
      original_length = length

      args[0] = from_native(key.map { |k| k.to_s }.join('.').to_sym)
      update_options(:scope, scope) # TODO fix positions!

      root.replace_src(row, column, original_length, to_ruby)
    end

    protected

      def compute_replacement_keys(search, replacement)
        search = normalize_keys(search)
        replacement = normalize_keys(replacement)

        key = normalize_keys(self.key)
        scope = normalize_keys(self.scope)
        all = scope + key

        all[key_index(search), search.length] = replacement
        if scope.empty?
          scope = nil
          key = all
        else
          key = all.slice!(-key.length, key.length) # i.e. we preserve the key length, this is debatable
          scope = all.empty? ? nil : all
          # scope = all.slice!(0, scope.length)     # this would preserve the scope length
          # key = all                               # comment this in, previous lines out and observe the tests
        end
        
        key = [scope.pop] if key.empty?
        scope = scope.first if scope && scope.size == 1
        scope = nil if scope && scope.empty?

        [key, scope]
      end

      def key_index(search)
        (all = full_key).each_index { |ix| return ix if all[ix, search.length] == search } and nil
      end

      def normalize_keys(*args)
        args.flatten.map { |k| k.to_s.split(/\./) }.
             flatten.map { |k| k.to_sym }
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