require 'ruby/node'

module Ruby
  class Assoc < Node
    child_accessor :key, :value, :operator
    
    def initialize(key, value, operator)
      self.key = key
      self.value = value
      self.operator = operator
      super(key.position)
    end
    
    def length(include_whitespace = false)
      key.length(include_whitespace) + operator.length(true) + value.length(true)
    end
    
    def to_ruby(include_whitespace = false)
      key.to_ruby(include_whitespace) + operator.to_ruby(true) + value.to_ruby(true)
    end
  end
end