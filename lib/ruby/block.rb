require 'ruby/identifier'

module Ruby
  class Body < Node
    attr_reader :statements
    
    def initialize(statements)
      @statements = statements.each { |s| s.parent = self } if statements
    end
    
    def children
      statements
    end

    def to_ruby
      statements.map { |s| s.to_ruby }.join("\n")
    end
  end
  
  class Block < Body
    attr_reader :params
    
    def initialize(statements, params)
      @params = params.tap { |p| p.parent = self } if params
      super(statements)
    end
    
    def children
      params
    end

    def to_ruby
      ruby = [' do' + (params ? " |#{params.to_ruby}|" : '') ]
      ruby << super
      ruby << 'end'
      ruby.join("\n")
    end
  end

  class ParamsList < Node # join with ArgsList?
    attr_accessor :params

    def initialize(params = [])
      @params = params.each { |v| v.parent = self } if params
    end
    
    def children
      params
    end

    def to_ruby
      map { |p| p.to_ruby }.join(', ')
    end

    def method_missing(method, *args, &block)
      @params.respond_to?(method) ? @params.send(method, *args, &block) : super
    end
  end

  class RestParam < Identifier
    def column
      super - 1
    end

    def to_ruby
      "*#{super}"
    end
  end
end