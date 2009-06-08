require 'ruby/node'

module Ruby
  class Array < Node
    child_accessor :elements, :separators
    attr_accessor :ldelim, :rdelim
    
    def initialize(elements, position, whitespace, ldelim, rdelim, separators)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.separators = Composite.collection(separators)
      self.elements = Composite.collection(elements)

      super(position, whitespace)
    end
    
    def <<(element)
      elements << element
      self
    end
    
    def length(include_whitespace = false)
      to_ruby(include_whitespace).length
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