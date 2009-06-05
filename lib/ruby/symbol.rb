require 'ruby/identifier'

module Ruby
  class Symbol < Identifier
    attr_accessor :literal
    
    def initialize(value, position)
      value = value.to_sym
      position[1] -= 1 if position
      super
    end

    def literal?
      !!@literal
    end
    
    def to_ruby
      ":#{super}"
    end
  end
  
  class DynaSymbol < String
    def initialize(value)
      super
    end
    
    def position
      super.tap { |position| position[1] -= 1 }
    end
    
    def value
      super.to_sym
    end
    
    def to_ruby
      ":#{super}"
    end
  end
end