require 'ruby/node'

module Ruby
  class ArgsList < Node
    child_accessor :args, :separators
    attr_accessor :ldelim, :rdelim

    def initialize(position = nil, whitespace = '', ldelim = '', rdelim = '', separators = [])
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.separators = Composite.collection(separators)
      self.args = Composite.collection

      super(position, whitespace)
    end

    def separators
      @separators ||= []
    end

    def length(include_whitespace = false)
      args.inject(0) { |sum, a| sum + a.length(true) } +
      separators.inject(0) { |sum, s| sum + s.length(true) } +
      ldelim.length + rdelim.length +
      (include_whitespace ? whitespace.length : 0)
    end

    def to_ruby(include_whitespace = false)
      ruby = zip(separators).flatten.compact.map { |el| el.to_ruby(true) }.join
      (include_whitespace ? whitespace : '') + ldelim.to_s + ruby + rdelim.to_s
    end

    def method_missing(method, *args, &block)
      self.args.respond_to?(method) ? self.args.send(method, *args, &block) : super
    end
  end

  class BlockArg < Node
    child_accessor :arg
    attr_accessor :ldelim
    
    def initialize(arg, position, ldelim)
      self.arg = arg
      self.ldelim = ldelim
      super(position)
    end

    def to_ruby(include_whitespace = false)
      ldelim.to_ruby(include_whitespace) + arg.to_ruby(true)
    end
  end
end