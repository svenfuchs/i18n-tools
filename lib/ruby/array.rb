require 'ruby/node'

module Ruby
  class Array < Node
    attr_accessor :elements, :ldelim, :rdelim, :separators
    
    def initialize(elements, position, whitespace, ldelim, rdelim, separators)
      @elements = elements.each { |v| v.parent = self }
      @ldelim = ldelim if ldelim
      @rdelim = rdelim if rdelim
      @separators = separators

      super(position, whitespace)
    end
    
    def children
      elements
    end
    
    def elements
      @elements ||= []
    end
    
    def separators
      @separators ||= []
    end
    
    def length(include_whitespace = false)
      ldelim.length(include_whitespace) + 
      elements.inject(0) { |sum, e| sum + e.length(true) } + 
      separators.inject(0) { |sum, s| sum + s.length(true) } + 
      rdelim.length(true)
    end
    
    def value
      map { |element| element.value }
    end

    def <<(element)
      position_from(element, 1) if empty?
      @elements << element.tap { |v| v.parent = self }
      self
    end
    
    def to_ruby
      ruby = (ldelim ? ldelim.to_ruby : '')
      ruby << zip(separators).flatten.compact.map { |el| el.to_ruby }.join
      ruby << (rdelim ? rdelim.to_ruby : '')
    end
    
    def method_missing(method, *args, &block)
      @elements.respond_to?(method) ? @elements.send(method, *args, &block) : super
    end
  end
end