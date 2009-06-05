require 'ruby/node'

module Ruby
  class Unary < Node
    attr_accessor :operator, :value

    def initialize(*args)
      @operator, @value = args
    end
    
    def column
      super - operator.to_s.length - ([:not].include?(operator) ? 1 : 0)
    end
    
    def position
      value.position
    end
    
    def length
      to_ruby.length
    end
    
    def to_ruby
      ruby = operator.to_s
      ruby << ' ' if [:not].include?(operator)
      ruby << value.to_ruby
    end
  end
  
  class Binary < Node
    attr_accessor :operator, :left, :right

    def initialize(*args)
      @operator, @left, @right = args
    end
    
    def position
      left.position
    end
    
    def length
      to_ruby.length
    end
    
    def to_ruby
      "#{left.to_ruby} #{operator} #{right.to_ruby}"
    end
  end
  
  class IfOp < Node
    attr_accessor :condition, :left, :right

    def initialize(*args)
      @condition, @left, @right = args
    end
    
    def position
      condition.position
    end
    
    def length
      to_ruby.length
    end
    
    def to_ruby
      "#{condition.to_ruby} ? #{left.to_ruby} : #{right.to_ruby}"
    end
  end
end