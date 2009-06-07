require 'ruby/args_list'

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
end