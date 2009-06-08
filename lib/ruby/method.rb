require 'ruby/node'

module Ruby
  class Method < Identifier
    child_accessor :params, :body

    def initialize(identifier, params, body)
      super(identifier.token, identifier.position)
      self.params = params
      self.body = body
    end
  end
end