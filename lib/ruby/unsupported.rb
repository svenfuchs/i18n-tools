require 'ruby/node'

module Ruby
  class Unsupported < Node 
    attr_accessor :value

    def initialize(value, position = nil)
      super(position)
      self.value = value
    end
    
    # def value=(value)
    #   value.parent = self if value.respond_to?(:parent=)
    #   @value = value
    # end
    
    def to_ruby
      '(unsupported type)'
    end
  end
end