require 'ruby/args'

module Ruby
  class Call < Node
    child_accessor :identifier, :target, :arguments, :block

    def initialize(target, identifier, arguments = nil, block = nil)
      target = Unsupported.new(target) if target && !target.is_a?(Node)

      self.target = target
      self.identifier = identifier
      self.arguments = arguments
      self.block = block
    end

    def token
      identifier.token
    end

    def position
      (target ? target.position : identifier.position).dup
    end
    
    def to_ruby(include_whitespace = false)
      ruby = if target
        target.to_ruby(include_whitespace) + '.' + identifier.to_ruby(true) # TODO extract the dot
      else
        identifier.to_ruby(include_whitespace)
      end
      ruby + 
      (arguments ? arguments.to_ruby(true) : '') + 
      (block ? block.to_ruby(true) : '')
    end
  end
end