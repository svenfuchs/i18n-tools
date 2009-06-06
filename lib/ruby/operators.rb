require 'ruby/node'

module Ruby
  class Unary < Node
    attr_accessor :operator, :operand

    def initialize(operator, operand)
      @operator = operator
      @operand = operand

      position_from(operand, operator.to_s.length + ([:not].include?(operator) ? 1 : 0))
    end
    
    def length
      to_ruby.length
    end
    
    def to_ruby
      ruby = operator.to_s
      ruby << ' ' if [:not].include?(operator)
      ruby << operand.to_ruby
    end
  end
  
  class Binary < Node
    attr_accessor :operator, :left, :right

    def initialize(operator, left, right)
      @operator = operator
      @left = left 
      @right = right
      @position = left.position
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

    def initialize(condition, left, right)
      @condition = condition
      @left = left
      @right = right
      @position = condition.position
    end
    
    def length
      to_ruby.length
    end
    
    def to_ruby
      "#{condition.to_ruby} ? #{left.to_ruby} : #{right.to_ruby}"
    end
  end
end