require 'ruby/node'

module Ruby
  class Call < Identifier
    attr_accessor :target, :block

    def initialize(target, identifier, arguments = nil)
      target = Unsupported.new(target) if target && !target.is_a?(Node)

      super(identifier.token, identifier.position)

      @target = target
      self.arguments = arguments.tap { |a| a.parent = self } if arguments
    end
    
    def children
      [target, arguments, block].compact
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
      ruby << super + arguments.to_ruby
      ruby << block.to_ruby if block
      ruby
    end
  end

  class ArgsList < Node
    attr_accessor :parentheses, :args
    
    def initialize(args = [], parentheses = false)
      @parentheses = parentheses
      @args = args.each { |a| a.parent = self }
    end
    
    def children
      args
    end
    
    def position
      @position ||= first.position.dup.tap { |p| p[1] -= 1 }
    end
    
    def <<(arg)
      arg = Unsupported.new(arg) if arg && !arg.is_a?(Node)
      @args << arg.tap { |v| v.parent = self }
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
      @args.respond_to?(method) ? @args.send(method, *args, &block) : super
    end
  end
end