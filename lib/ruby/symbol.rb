require 'ruby/identifier'

module Ruby
  class Symbol < Token
    attr_accessor :ldelim
    
    def initialize(token, ldelim)
      @ldelim = ldelim
      super(token)
    end
    
    def value
      token.to_sym
    end
    
    def position
      ldelim.position
    end
    
    def length(include_whitespace = false)
      ldelim.length(include_whitespace) + token.length
    end
    
    def to_ruby
      (ldelim ? ldelim.to_ruby : '') + super(true)
    end
  end
  
  class DynaSymbol < String
    def value
      super.to_sym
    end
  end
end