require 'ruby/node'

module Ruby
  class Assignment < Node
    child_accessor :left, :right, :operator

    def initialize(left, right, operator)
      self.left = left
      self.right = right
      self.operator = operator
      super(left.position)
    end

    def to_ruby(include_whitespace = false)
      left.to_ruby(include_whitespace) +
      operator.to_ruby(true) +
      right.to_ruby(true)
    end
  end

  class MultiAssignment < Node
    attr_accessor :kind
    child_accessor :refs, :separators, :ldelim, :rdelim, :star

    def initialize(kind, ldelim = nil, rdelim = nil, separators = [], star = nil, refs = [])
      self.kind = kind
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.star = star
      self.separators = separators
      self.refs = refs
    end

    def position
      @position ||= ldelim ? ldelim.position.dup : refs.first.position.dup
    end

    def to_ruby(include_whitespace = false)
      nodes = [ldelim, star, zip(separators), rdelim].flatten.compact
      nodes[0].to_ruby(include_whitespace) + nodes[1..-1].map { |node| node.to_ruby(true) }.join
    end

    def method_missing(method, *args, &block)
      @refs.respond_to?(method) ? @refs.send(method, *args, &block) : super
    end
  end
end