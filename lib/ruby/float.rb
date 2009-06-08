module Ruby
  class Float < Identifier
    def value
      token.to_f
    end
    
    def to_ruby(include_whitespace = false)
      super(include_whitespace).to_s
    end
  end
end