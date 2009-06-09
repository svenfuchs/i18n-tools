require 'ruby/node'

module Ruby
  class ArgsList < Node
    child_accessor :args, :separators
    attr_accessor :ldelim, :rdelim

    def initialize(position = nil)
      self.args = []
      self.separators = []

      super(position, whitespace)
    end

    def length(include_whitespace = false)
      args.inject(0) { |sum, a| sum + a.length(true) } +
      separators.inject(0) { |sum, s| sum + s.length(true) } +
      ldelim.length + rdelim.length +
      (include_whitespace ? whitespace.length : 0)
    end
    
    def pop
      arg = args.pop
      sep = separators.pop
      [arg, sep]
    end
    
    def options
      last.is_a?(Ruby::Hash) ? last : (self << Hash.new(nil, '', nil, nil)) # TODO fix positions!
    end
    
    def update_options(key, value)
      value ? options[key] = from_ruby(' ' + value.inspect) : options.delete(key)
      pop if last.empty?
    end

    def to_ruby(include_whitespace = false)
      nodes = [ldelim, zip(separators), rdelim].flatten.compact
      return '' if nodes.empty?
      nodes[0].to_ruby(include_whitespace) + nodes[1..-1].map { |node| node.to_ruby(true) }.join
    end

    def method_missing(method, *args, &block)
      self.args.respond_to?(method) ? self.args.send(method, *args, &block) : super
    end
    
    def from_ruby(src)
      Ripper::RubyBuilder.new(src).parse.statements.first
    end
  end

  class BlockArg < Node
    child_accessor :arg
    attr_accessor :ldelim
    
    def initialize(arg, ldelim)
      self.arg = arg
      self.ldelim = ldelim
      super(ldelim.position)
    end

    def to_ruby(include_whitespace = false)
      ldelim.to_ruby(include_whitespace) + arg.to_ruby(true)
    end
  end
end