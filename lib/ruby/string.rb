require 'ruby/node'

module Ruby
  class String < Node
    attr_accessor :contents, :ldelim, :rdelim
    
    def initialize(contents, ldelim = nil, rdelim = nil)
      @ldelim = ldelim if ldelim
      @rdelim = rdelim if rdelim

      if contents
        contents.each { |c| self << c } 
        ldelim ||= contents.first.ldelim
      end

      super(ldelim.position)
    end
    
    def children
      contents
    end
    
    def contents
      @contents ||= []
    end

    def <<(content)
      contents << content.tap { |c| c.parent = self }
    end
    
    def whitespace
      ldelim.whitespace
    end
    
    def length(include_whitespace = false)
      (ldelim ? ldelim.length(include_whitespace) : 0) +
      contents.inject(0) { |sum, c| sum + c.length} + 
      (rdelim ? rdelim.length(include_whitespace) : 0)
    end

    def value
      map { |content| content.value }.join
    end

    def to_ruby
      ldelim.to_ruby + map { |content| content.to_ruby }.join + rdelim.to_ruby
    end
    
    def method_missing(method, *args, &block)
      @contents.respond_to?(method) ? @contents.send(method, *args, &block) : super
    end
  end

  class StringContent < Token
    def quote
      line[column - 1]
    end
    
    def value
      token
    end
  end
end