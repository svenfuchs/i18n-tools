require 'ruby/node'

module Ruby
  class Unary < Node
    attr_accessor :operator, :operand

    def initialize(operator, operand)
      self.operator = operator
      self.operand = operand
    end
    
    def position
      operator.position.dup
    end
    
    def to_ruby(include_whitespace = false)
      operator.to_ruby(include_whitespace) +
      operand.to_ruby(true)
    end
  end
  
  class Binary < Node
    attr_accessor :operator, :left, :right

    def initialize(operator, left, right)
      self.operator = operator
      self.left = left 
      self.right = right
    end
    
    def position
      left.position.dup
    end
    
    def to_ruby(include_whitespace = false)
      left.to_ruby(include_whitespace) + 
      operator.to_ruby(true) +
      right.to_ruby(true)
    end
  end
  
  class IfOp < Node
    attr_accessor :condition, :left, :right, :operators

    def initialize(condition, left, right, operators)
      self.condition = condition
      self.left = left
      self.right = right
      self.operators = operators
    end
    
    def position
      condition.position.dup
    end
    
    def to_ruby(include_whitespace = false)
      condition.to_ruby(include_whitespace) +
      operators.zip([left, right]).flatten.map { |node| node.to_ruby(true) }.join
    end
  end
end