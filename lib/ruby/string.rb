require 'ruby/node'

module Ruby
  class String < Node
    child_accessor :contents
    attr_accessor :ldelim, :rdelim
    
    def initialize(position, whitespace, ldelim, rdelim = nil)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.contents = Composite.collection
      super(position, whitespace)
    end
    
    def value
      map { |content| content.value }.join
    end
    
    def length(include_whitespace = false)
      contents.inject(0) { |sum, c| sum + c.length} + 
      (ldelim ? ldelim.length : 0) +
      (rdelim ? rdelim.length : 0) + 
      (include_whitespace ? whitespace.length : 0)
    end

    def to_ruby(include_whitespace = false)
      (include_whitespace ? whitespace : '') + ldelim + map { |content| content.to_ruby }.join + rdelim
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