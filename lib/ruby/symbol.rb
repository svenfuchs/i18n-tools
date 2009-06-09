require 'ruby/identifier'

module Ruby
  class Symbol < Token
    child_accessor :ldelim
    
    def initialize(token, ldelim)
      self.ldelim = ldelim
      super(token)
    end
    
    def position
      ldelim.position.dup
    end
    
    def position=(position)
      ldelim.position = position
    end
    
    def whitespace
      ldelim.whitespace
    end
    
    def value
      token.to_sym
    end
    
    def to_ruby(include_whitespace = false)
      ldelim.to_ruby(include_whitespace) + token
    end
  end
  
  class DynaSymbol < String
    def value
      super.to_sym
    end
  end
end