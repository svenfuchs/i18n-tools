require 'ruby/params'

module Ruby
  class Body < Node
    child_accessor :statements
    
    def initialize(statements)
      self.statements = Composite.collection(statements)
    end
    
    def to_ruby(include_whitespace = false)
      statements.first.to_ruby(include_whitespace) +
      statements[1..-1].map { |s| s.to_ruby(true) }.join
    end
  end
  
  class Block < Body
    child_accessor :params, :rdelim, :ldelim
    
    def initialize(statements, params)
      self.params = params
      super(statements)
    end
    
    def to_ruby(include_whitespace = false)
      ldelim.to_ruby(include_whitespace) + 
      (params ? params.to_ruby(true) : '') +
      super(true) +
      rdelim.to_ruby(true)
    end
  end
end