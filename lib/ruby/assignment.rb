require 'ruby/node'

module Ruby
  class Assignment < Node
    attr_accessor :left, :right

    def initialize(left, right)
      @left = left.tap { |c| c.parent = self }
      @right = right.tap { |c| c.parent = self }
    end
    
    def position
      @position ||= [left.row, left.column - 1]
    end
    
    def to_ruby
      left.to_ruby + " = " + right.to_ruby
    end
  end
  
  class MultiAssignment < Node
    attr_accessor :refs, :star, :parentheses

    def initialize(position = :left, refs = [])
      @position = position
      @refs = refs.each { |r| r.parent = self }
    end
    
    def <<(ref)
      refs << ref.tap { |v| v.parent = self }
      self
    end
    
    def star?
      !!star
    end
    
    def parentheses?
      !!parentheses
    end
    
    def position
      [first.row, first.column - 1]
    end
    
    def to_ruby
      ruby = (star? ? '*' : '')
      ruby << map { |e| e.to_ruby }.join(', ')
      ruby = "(#{ruby})" if parentheses?
      ruby
    end
    
    def method_missing(method, *args, &block)
      @refs.respond_to?(method) ? @refs.send(method, *args, &block) : super
    end
  end
end