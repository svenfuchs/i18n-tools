require 'ruby/node'

module Ruby
  class Program < Node
    attr_accessor :src, :filename
    child_accessor :statements

    def initialize(src, filename, statements)
      self.src = src
      self.filename = filename
      self.statements = filter_statements(statements).each { |s| s.parent = self }
      super([0, 0])
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
    
    # get rid of unsupported sexp nodes
    def filter_statements(statements)
      Array(statements).flatten.select { |s| s.kind_of?(Ruby::Node) }
    end
  end
end