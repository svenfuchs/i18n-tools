require 'ruby/node'

module Ruby
  class ArgsList < Node
    attr_accessor :args, :ldelim, :rdelim, :separators
    
    def initialize(args = [], ldelim = nil, rdelim = nil)
      @args = args.each { |a| a.parent = self }
      @ldelim = ldelim if ldelim
      @rdelim = rdelim if rdelim
    end
    
    def children
      args
    end
    
    def separators
      @separators ||= []
    end
    
    def position
      @position ||= first.position.dup.tap { |p| p[1] -= 1 }
    end
    
    def <<(arg)
      arg = Unsupported.new(arg) if arg && !arg.is_a?(Node)
      @args << arg.tap { |v| v.parent = self }
      self
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