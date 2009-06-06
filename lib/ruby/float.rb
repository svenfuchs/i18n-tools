module Ruby
  class Float < Identifier
    def value
      token.to_f
    end
    
    def to_ruby
      super.to_s
    end
  end
end