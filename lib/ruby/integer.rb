module Ruby
  class Integer < Identifier
    def initialize(value, position = nil)
      super(value.to_i, position)
    end
    
    def to_ruby
      super.to_s
    end
  end
end