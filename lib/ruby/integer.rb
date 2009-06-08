module Ruby
  class Integer < Identifier
    def value
      token.to_i
    end
    
    def to_ruby(include_whitespace = false)
      super(include_whitespace).to_s
    end
  end
end