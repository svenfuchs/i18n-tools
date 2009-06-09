require 'ruby/node'

module Ruby
  class Method < Identifier
    child_accessor :params, :body

    def initialize(token, position, params, body)
      super(token, position)
      self.params = params
      self.body = body
    end
  end
end