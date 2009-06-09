require 'ruby/identifier'

module Ruby
  class ParamsList < Node # join with ArgsList?
    child_accessor :params, :separators, :ldelim, :rdelim

    def initialize(params, whitespace, ldelim, rdelim, separators)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.separators = separators
      self.params = params

      position = ldelim ? ldelim.position : params.first.position rescue nil
      super(position, whitespace)
    end
    
    def to_ruby(include_whitespace = false)
      (ldelim ? ldelim.to_ruby(include_whitespace) : '') + 
      zip(separators).flatten.compact.map { |el| el.to_ruby(true) }.join + 
      (rdelim ? rdelim.to_ruby(true) : '')
    end

    def method_missing(method, *args, &block)
      @params.respond_to?(method) ? @params.send(method, *args, &block) : super
    end
  end

  class RestParam < Identifier
    def initialize(token, position, ldelim)
      @ldelim = ldelim
      super(token, position)
    end
    
    def column
      super - 1
    end

    def to_ruby(include_whitespace = false)
      @ldelim.to_ruby(include_whitespace) + super(true)
    end
  end
end