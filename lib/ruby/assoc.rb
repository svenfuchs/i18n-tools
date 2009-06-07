require 'ruby/node'

module Ruby
  class Assoc < Node
    attr_reader :key, :value, :operator
    
    def initialize(key, value, operator)
      self.key = key
      self.value = value
      @operator = operator
      super()
    end
    
    def children
      [key, value]
    end
    
    def length(include_whitespace = false)
      key.length(include_whitespace) + operator.length(true) + value.length(true)
    end

    def value=(value)
      value = Unsupported.new(value) if value && !value.is_a?(Node)
      @value = value.tap { |v| v.parent = self }
    end

    def key=(key)
      key = Unsupported.new(key) unless key.is_a?(Node)
      @key = key.tap { |k| k.parent = self }
    end
    
    def to_ruby
      key.to_ruby + operator.to_ruby + value.to_ruby
    end
  end
end