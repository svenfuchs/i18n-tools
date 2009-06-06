require 'ruby/node'

module Ruby
  class Program < Node
    attr_accessor :statements

    def initialize(src, filename = nil, statements = [])
      @src = src
      @filename = filename
      self.statements = statements
      @position = [0, 0]
    end
    
    def children
      statements
    end
    
    def statements=(statements)
      @statements = find_statement(statements).each do |statement|
        statement.parent = self
      end
    end
  
    def statement(&block)
      @statements.each { |s| return s if yield(s) }
    end
    
    def replace_src(row, column, length, src)
      @src[line_pos(row) + column, length] = src
       
      offset_column = src.length - length
      update_positions(row, column + length, offset_column)
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