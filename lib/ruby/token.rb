require 'ruby/node'

module Ruby
  class Token < Node 
    attr_accessor :token

    def initialize(token, position = nil, whitespace = '')
      self.token = token
      super(position, whitespace)
    end
    
    def to_ruby(include_whitespace = false)
      (include_whitespace ? whitespace : '') + token
    end
  end
end