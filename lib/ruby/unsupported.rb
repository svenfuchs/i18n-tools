require 'ruby/node'

module Ruby
  class Unsupported < Node 
    attr_accessor :token

    def initialize(token, position = nil)
      super(position)
      self.token = token
    end
    
    def to_ruby
      '(unsupported type)'
    end
  end
end