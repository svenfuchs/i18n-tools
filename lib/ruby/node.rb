module Ruby
  class Node
    include Ansi

    attr_reader :parent, :filename, :children

    def initialize(position = nil, filename = nil)
      @position = position
      @filename = filename
      @children = []
    end
    
    def parent=(parent)
      @parent = parent
    end
    
    def position
      @position or raise("position not set in #{self.inspect}")
    end
    
    def row
      position[0]
    end

    def column
      position[1]
    end

    def length
      to_ruby.length
    end
    
    def root?
      parent.nil?
    end
    
    def root
      root? ? self : parent.root
    end

    def src_pos
      line_pos(row) + column
    end
    
    def src
      root? ? @src : line[column, length]
    end

    def filename
      @filename || parent && parent.filename
    end

    def lines
      root.src.split("\n")
    end
    
    def line_pos(row)
      (row > 0 ? lines[0..(row - 1)].inject(0) { |pos, line| pos + line.length + 1 } : 0)
    end

    # TODO what if a node spans multiple lines (like a block, method definition, ...)?
    def line(highlight = false)
      line = lines[row].dup
      highlight ? line_head + ansi_format(to_ruby, [:red, :bold]) + line_tail : line
    end

    # excerpt from source, preceding and succeeding [Ruby.context_width] lines
    def context(highlight = false)
      (context_head + [line(highlight)] + context_tail).join("\n")
    end
    
    def context_head
      min = [0, row - Ruby.context_width].max
      min < row ? lines[min..(row - 1)] : []
    end
    
    def context_tail
      max = [row + Ruby.context_width, lines.size].min
      max > row ? lines[(row + 1)..max] : []
    end

    # all content that precedes the node in the first line of the node in source
    def line_head
      line[0..(column - 1)].to_s
    end

    # all content that succeeds the node in the last line of the node in source
    def line_tail
      line[(column + length - 1)..-1].to_s
    end
    
    protected
    
      def position_from(node, column_offset = 0)
        @position = node.position.dup
        @position[1] -= column_offset
      end
      
      def update_positions(row, column, offset_column)
        position[1] += offset_column if self.row == row && self.column > column
        children.each { |c| c.update_positions(row, column, offset_column) }
      end
  end
end