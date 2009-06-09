require 'ruby/node'

module Ruby
  class String < Node
    child_accessor :contents, :ldelim, :rdelim
    
    def initialize(ldelim, rdelim = nil)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.contents = Composite.collection
      super(ldelim.position)
    end
    
    def value
      map { |content| content.value }.join
    end
    
    def src_pos(include_whitespace = false)
      ldelim.src_pos(include_whitespace)
    end
    
    def length(include_whitespace = false)
      (rdelim ? rdelim.length(true) : 0) +
      contents.inject(0) { |sum, c| sum + c.length(include_whitespace) } + 
      (ldelim ? ldelim.length(include_whitespace) : 0)
    end

    def to_ruby(include_whitespace = false)
      ldelim.to_ruby(include_whitespace) + 
      map { |content| content.to_ruby(true) }.join + 
      rdelim.to_ruby(true)
    end
    
    def method_missing(method, *args, &block)
      contents.respond_to?(method) ? contents.send(method, *args, &block) : super
    end
  end

  class StringContent < Token
    def value
      token
    end
  end
end