require 'ruby/identifier'

module Ruby
  class Symbol < Identifier
    attr_accessor :literal
    
    def initialize(token, position)
      super
      @position[1] -= 1 if @position
    end
    
    def value
      token.to_sym
    end

    def literal?
      !!@literal
    end
    
    def to_ruby
      ":#{super}"
    end
  end
  
  class DynaSymbol < String
    def initialize(string)
      super
      @position[1] -= 1 if @position
    end
    
    # def position
    #   super.tap { |position| position[1] -= 1 }
    # end
    
    def value
      super.to_sym
    end
    
    def to_ruby
      ":#{super}"
    end
  end
end