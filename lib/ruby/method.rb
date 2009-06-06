require 'ruby/node'

module Ruby
  class Method < Identifier
    attr_accessor :params, :body

    def initialize(identifier, params, body)
      super(identifier.token, identifier.position)
      @params, @body = params, body
      @params.parent = self
      @body.parent = self
    end
    
    def children
      [params, body]
    end
  end
end