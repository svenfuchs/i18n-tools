require 'ruby/call'
require 'i18n/ruby/call'

module Ruby
  module TranslateArgsList
    def full_key(joined = false)
      full_key = normalize_keys(scope, key)
      joined ? join_key(full_key) : full_key
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

    def replace_key!(search, replace)
      original_length = length
      self.key, self.scope = compute_replace_keys(search, replace)
      root.replace_src(row, column, original_length, to_ruby)
    end

    protected
    
      def key=(key)
        self[0] = key
      end
    
      def scope=(scope)
        if scope
          set_option(:scope, scope)
        elsif options
          options.delete(:scope)
          pop if options.empty?
        end
      end

      def compute_replace_keys(search, replace)
        search  = normalize_keys(search)
        replace = normalize_keys(replace)
        key     = normalize_keys(self.key)
        scope   = normalize_keys(self.scope)
        all     = scope + key

        all[key_index(search), search.length] = replace

        if scope.empty?
          key = all
        else
          key = all.slice!(-[key.length, all.size].min..-1) # i.e. we preserve the key length, this is debatable
          scope = all.empty? ? nil : all
          # scope = all.slice!(0, scope.length)     # this would preserve the scope length
          # key = all                               # comment this in, previous lines out and observe the tests
        end
        
        key = [scope.pop] if key.empty?
        scope = scope.first if scope && scope.size == 1
        scope = nil if scope && scope.empty?

        [join_key(key), scope]
      end

      def key_index(search)
        (all = full_key).each_index { |ix| return ix if all[ix, search.length] == search } and nil
      end
      
      def join_key(key)
        key.map { |k| k.to_s }.join('.').to_sym
      end

      def normalize_keys(*args)
        args.flatten.
            map { |k| k.to_s.split(/\./) }.flatten.
            reject { |k| k.empty? }.
            map { |k| k.to_sym }
      end
  end
end