module Ruby
  class Node
    include Ansi

    attr_reader :parent, :position, :filename

    def initialize(position, filename = nil)
      @position = position
      @filename = filename
    end
    
    def parent=(parent)
      @parent = parent
    end
    
    def row
      position[0] rescue raise("position not set in #{self.inspect}")
    end

    def column
      position[1] rescue raise("position not set in #{self.inspect}")
    end

    def length
      to_ruby.length
    end

    def src
      parent ? parent.src : @src
    end

    def filename
      @filename || parent && parent.filename
    end

    def lines
      @lines ||= src.split("\n")
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

    def src_pos
      (row > 0 ? lines[0..(row - 1)].inject(0) { |pos, line| pos + line.length + 1 } : 0) + column
    end

    # all content that precedes the node in the first line of the node in source
    def line_head
      line[0..(column - 1)].to_s
    end

    # all content that succeeds the node in the last line of the node in source
    def line_tail
      line[(column + length - 1)..-1].to_s
    end
  end
end