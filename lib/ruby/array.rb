require 'ruby/node'

module Ruby
  class Array < Node
    attr_reader :elements
    
    def initialize(elements)
      if elements
        @elements = elements.each { |v| v.parent = self }
        position_from(elements.first, 1) # TODO doen't take whitespace into account
      end
    end
    
    def children
      elements
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
      '[' + map { |element| element.to_ruby }.join(', ') + ']'
    end
    
    def method_missing(method, *args, &block)
      @elements.respond_to?(method) ? @elements.send(method, *args, &block) : super
    end
  end
end