require 'ruby/node'

module Ruby
  class Identifier < Node 
    attr_accessor :token

    def initialize(token, position = nil)
      super(position)
      self.token = token
    end
    
    def token=(token)
      @token = token.tap { |t| t.parent = self if t.respond_to?(:parent=) }
    end
    
    # def position
    #   @position || value.respond_to?(:position) && value.position || raise("position not set")
    # end
    
    # def to_symbol
    #   Ruby::Symbol.new(value, position)
    # end
    
    def to_ruby
      # token.respond_to?(:to_ruby) ? token.to_ruby : token
      token
    end
  end
end