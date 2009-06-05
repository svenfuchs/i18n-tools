require 'ruby/identifier'

module Ruby
  class Class < Identifier
    attr_accessor :const, :super_class, :body

    def initialize(const, super_class, body)
      @const, @super_class, @body = const, super_class, body
      @const.parent = self if const
      @super_class.parent = self if super_class
      @body.parent = self if body
    end
    
    def to_ruby
      ruby = "class #{const.to_ruby}"
      ruby << " < #{super_class.to_ruby}" if super_class
      ruby << "\n" << body.to_ruby
      ruby << "\nend"
    end
  end
end