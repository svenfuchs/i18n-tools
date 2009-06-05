require 'ruby/node'

module Ruby
  class Call < Node
    attr_accessor :target, :identifier, :block

    def initialize(target, identifier, arguments = nil)
      target = Unsupported.new(target) if target && !target.is_a?(Node)
      identifier = Unsupported.new(identifier) if identifier && !identifier.is_a?(Node)

      @target = target
      @identifier = identifier
      self.arguments = arguments.tap { |a| a.parent = self } if arguments
    end
    
    def position
      identifier.position
    end
    
    def arguments
      @arguments ||= ArgsList.new.tap { |a| a.parent = self }
    end
    
    def arguments=(arguments)
      @arguments = arguments.tap { |a| a.parent = self }
    end
    
    def block=(block)
      @block = block.tap { |b| b.parent = self }
    end
    
    def to_ruby
      ruby = ''
      ruby << target.to_ruby + '.' if target
      ruby << identifier.to_ruby + arguments.to_ruby
      ruby << block.to_ruby if block
      ruby
    end
  end

  class ArgsList < Node
    attr_accessor :parentheses, :values
    
    def initialize(values = [], parentheses = false)
      @parentheses = parentheses
      @values = values.each { |v| v.parent = self }
    end
    
    def position
      @position ||= first.position.dup.tap { |p| p[1] -= 1 }
    end
    
    def <<(value)
      value = Unsupported.new(value) if value && !value.is_a?(Node)
      @values << value.tap { |v| v.parent = self }
      self
    end

    def parentheses?
      !!@parentheses
    end
    
    def to_ruby
      ruby = map { |arg| arg.to_ruby }.compact.join(', ')
      ruby = "(#{ruby})" if parentheses?
      ruby = " #{ruby}" unless parentheses? or empty?
      ruby
    end
    
    def method_missing(method, *args, &block)
      @values.respond_to?(method) ? @values.send(method, *args, &block) : super
    end
  end
end