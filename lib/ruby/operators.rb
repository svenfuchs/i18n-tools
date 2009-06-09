require 'ruby/node'

module Ruby
  class Unary < Node
    attr_accessor :operator, :operand

    def initialize(operator, operand)
      self.operator = operator
      self.operand = operand

      position = operand.position.dup
      position[1] -= operator.to_s.length + ([:not].include?(operator) ? 1 : 0)
      super(position)
    end
    
    def length(include_whitespace = false)
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
      self.operator = operator
      self.left = left 
      self.right = right
      super(left.position)
    end
    
    def length(include_whitespace = false)
      to_ruby.length
    end
    
    def to_ruby
      "#{left.to_ruby} #{operator} #{right.to_ruby}"
    end
  end
  
  class IfOp < Node
    attr_accessor :condition, :left, :right

    def initialize(condition, left, right)
      self.condition = condition
      self.left = left
      self.right = right
      super(condition.position)
    end
    
    def length(include_whitespace = false)
      to_ruby.length
    end
    
    def to_ruby
      "#{condition.to_ruby} ? #{left.to_ruby} : #{right.to_ruby}"
    end
  end
end