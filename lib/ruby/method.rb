require 'ruby/node'

module Ruby
  class Method < Node
    attr_accessor :identifier, :params, :body

    def initialize(identifier, params, body)
      @identifier, @params, @body = identifier, params, body
      @identifier.parent = self
      @params.parent = self
      @body.parent = self
    end
  end
end