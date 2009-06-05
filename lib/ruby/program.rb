require 'ruby/node'

module Ruby
  class Program < Node
    attr_accessor :statements

    def initialize(src, filename = nil, statements = [])
      @src = src
      @filename = filename
      self.statements = statements
    end
    
    def statements=(statements)
      @statements = find_statement(statements).each do |statement|
        statement.parent = self
      end
    end
    
    def to_ruby
      statements.map { |s| s.to_ruby }.join("\n")
    end
    
    # need to get rid of unsupported sexp nodes
    def find_statement(statements)
      Array(statements).flatten.select { |s| s.kind_of?(Ruby::Node) }
    end
  end
end