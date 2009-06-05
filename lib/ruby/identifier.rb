require 'ruby/node'

module Ruby
  class Identifier < Node 
    attr_accessor :value

    def initialize(value, position = nil)
      super(position)
      self.value = value
    end
    
    def value=(value)
      value.parent = self if value.respond_to?(:parent=)
      @value = value
    end
    
    def position
      @position || value.respond_to?(:position) && value.position || raise("position not set")
    end
    
    def to_symbol
      Ruby::Symbol.new(value, position)
    end
    
    def to_ruby
      value.respond_to?(:to_ruby) ? value.to_ruby : value
    end
  end
end