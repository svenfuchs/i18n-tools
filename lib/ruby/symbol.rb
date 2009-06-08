require 'ruby/identifier'

module Ruby
  class Symbol < Token
    attr_accessor :ldelim
    
    def initialize(token, position, whitespace, ldelim)
      super(token, position, whitespace)
      @ldelim = ldelim
    end
    
    def value
      token.to_sym
    end
    
    def length(include_whitespace = false)
      ldelim.length + token.length + (include_whitespace ? whitespace.length : 0)
    end
    
    def to_ruby(include_whitespace = false)
      (include_whitespace ? whitespace : '') + ldelim + token
    end
  end
  
  class DynaSymbol < String
    def value
      super.to_sym
    end
  end
end