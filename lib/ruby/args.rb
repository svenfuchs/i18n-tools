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
      root.update_positions(arg.row, arg.column + arg.length, arg.length - self[ix].length)
      args[ix] = arg
    end
    
    def pop
      arg = args.pop
      sep = separators.pop
      [arg, sep]
    end
    
    def options
      last.is_a?(Ruby::Hash) ? last : (self << Hash.new(nil, nil, nil)) # TODO fix positions!
    end
    
    def update_options(key, value)
      value ? options[key] = from_ruby(' ' + value.inspect) : options.delete(key)
      pop if last.empty?
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