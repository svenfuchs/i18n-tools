require 'ruby/node'

module Ruby
  class Array < Node
    child_accessor :elements, :separators, :ldelim, :rdelim
    # do |l| l.position = l.parent.position if l.parent.position end
    
    def initialize(elements, ldelim, rdelim = nil, separators = nil)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.elements = elements || []
      self.separators = separators || []
    end
    
    def position
      ldelim.position.dup
    end
    
    def <<(element)
      elements << element
      self
    end
    
    def value
      map { |element| element.value }
    end
    
    def to_ruby(include_whitespace = false)
      (ldelim ? ldelim.to_ruby(include_whitespace) : '') + 
      zip(separators).flatten.compact.map { |el| el.to_ruby(true) }.join + 
      (rdelim ? rdelim.to_ruby(true) : '')
    end
    
    def method_missing(method, *args, &block)
      elements.respond_to?(method) ? elements.send(method, *args, &block) : super
    end
  end
end