require 'ruby/const'

module Ruby
  class Class < Const
    attr_accessor :super_class, :body

    def initialize(const, super_class, body)
      position = const.position
      position[1] -= 6 # TODO take whitespace into account

      super(const.token, position)

      @super_class, @body = super_class, body
      @super_class.parent = self if super_class
      @body.parent = self if body
    end

    def children
      [super_class, body]
    end

    def to_ruby
      ruby = "class #{super}"
      ruby << " < #{super_class.to_ruby}" if super_class
      ruby << "\n" << body.to_ruby
      ruby << "\nend"
    end
  end
end