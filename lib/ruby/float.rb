module Ruby
  class Float < Identifier
    def initialize(value, position = nil)
      super(value.to_f, position)
    end
    
    def to_ruby
      super.to_s
    end
  end
end