module I18n
  module Index
    class Key
      class << self
        def patterns(*keys)
          keys.inject({}) { |result, key| result[key] = pattern(key); result }
        end

        def pattern(key)
          key = key.to_s.dup
          match_start = key.gsub!(/^\*/, '') ? '' : '^'
          match_end = key.gsub!(/\*$/, '') ? '' : '$'
          pattern = Regexp.escape("#{key}")
          /#{match_start}#{pattern}#{match_end}/
        end
      end
      
      attr_accessor :key
      
      def initialize(key)
        self.key = key
      end
      
      def matches?(*keys)
        patterns = Key.patterns(*keys)
        patterns.empty? || patterns.any? do |key, pattern|
          self.key == key.to_sym || self.key.to_s =~ pattern
        end
      end
      
      def <=>(other)
        key <=> other.key
      end
      
      def ==(other)
        key == (other.respond_to?(:key) ? other.key : other)
      end
      alias eql? ==
      
      def hash
        key.hash
      end
    end
  end
end