require 'ruby/identifier'

module Ruby
  class Symbol < Token
    child_accessor :ldelim
    
    def initialize(token, ldelim)
      self.ldelim = ldelim
      super(token, ldelim.position)
    end
    
    def value
      token.to_sym
    end
    
    def whitespace
      ldelim.whitespace # TODO remove this?
    end
    
    def length(include_whitespace = false)
      ldelim.length(include_whitespace) + token.length
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