require 'ruby/const'

module Ruby
  class Class < Const
    child_accessor :super_class, :body

    def initialize(const, super_class, body)
      position = const.position
      position[1] -= 6 # TODO take whitespace into account

      self.super_class = super_class
      self.body = body

      super(const.token, position)
    end

    def to_ruby
      ruby = "class #{super}"
      ruby << " < #{super_class.to_ruby}" if super_class
      ruby << "\n" << body.to_ruby
      ruby << "\nend"
    end
  end
end