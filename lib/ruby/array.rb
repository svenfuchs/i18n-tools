require 'ruby/node'

module Ruby
  class Array < Node
    def initialize(values)
      @values = values.each { |v| v.parent = self } if values
    end
    
    def value
      map { |element| element.value }
    end

    def <<(value)
      @values << value.tap { |v| v.parent = self }
      self
    end
    
    def position
      raise "empty array ... now what?" if empty?
      [first.row, first.column - 1]
    end
    
    def to_ruby
      '[' + map { |value| value.to_ruby }.join(', ') + ']'
    end
    
    def method_missing(method, *args, &block)
      @values.respond_to?(method) ? @values.send(method, *args, &block) : super
    end
  end
end