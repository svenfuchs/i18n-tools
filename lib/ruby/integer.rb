module Ruby
  class Integer < Identifier
    def value
      token.to_i
    end
    
    def to_ruby
      super.to_s
    end
  end
end