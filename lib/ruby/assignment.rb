require 'ruby/node'

module Ruby
  class Assignment < Node
    child_accessor :left, :right, :operator

    def initialize(left, right, operator)
      self.left = left
      self.right = right
      self.operator = operator
    end

    def position
      @position ||= [left.row, left.column - 1]
    end

    def to_ruby(include_whitespace = false)
      left.to_ruby(include_whitespace) +
      operator.to_ruby(true) +
      right.to_ruby(true)
    end
  end

  class MultiAssignment < Node
    child_accessor :refs, :separators, :star
    attr_accessor :kind, :ldelim, :rdelim

    def initialize(kind, ldelim = nil, rdelim = nil, separators = [], star = nil, refs = [])
      self.kind = kind
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.star = star
      self.separators = Composite.collection(separators)
      self.refs = Composite.collection(refs)
    end

    def position
      [first.row, first.column - 1]
    end

    def to_ruby(include_whitespace = false)
      (ldelim ? ldelim.to_ruby(include_whitespace) : '') +
      (star ? star.to_ruby(true) : '') +
      zip(separators).flatten.compact.map { |el| el.to_ruby(true) }.join +
      (rdelim ? rdelim.to_ruby(include_whitespace) : '')
    end

    def method_missing(method, *args, &block)
      @refs.respond_to?(method) ? @refs.send(method, *args, &block) : super
    end
  end
end