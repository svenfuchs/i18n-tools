require 'ruby/node'

module Ruby
  class ArgsList < Node
    child_accessor :args, :separators, :ldelim, :rdelim

    def initialize
      self.args = []
      self.separators = []
    end
      
    def []=(ix, arg)
      arg.position = self[ix].position
      super
    end
    
    def pop
      arg = args.pop
      sep = separators.pop
      [arg, sep]
    end
    
    def options
      last.is_a?(Ruby::Hash) ? last : nil # TODO fix position!
    end
    
    def update_options(key, value)
      if value
        if options
          options[key] = from_native(value, nil, ' ') # TODO fix position!
        else
          self << from_native(key => value)
        end
      else
        if options
          options.delete(key)
          pop if last.empty?
        end
      end
    end
    
    def nodes
      [ldelim, zip(separators), rdelim].flatten.compact
    end

    def method_missing(method, *args, &block)
      self.args.respond_to?(method) ? self.args.send(method, *args, &block) : super
    end
  end

  class BlockArg < Node
    child_accessor :arg
    attr_accessor :ldelim
    
    def initialize(arg, ldelim)
      self.arg = arg
      self.ldelim = ldelim
    end
    
    def nodes
      [ldelim, arg]
    end
  end
end