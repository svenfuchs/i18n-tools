require File.dirname(__FILE__) + '/../../ansi'

module I18n
  module Keys
    # Represents a piece of source code (i.e. a bunch of characters)
    class Range
      include Ansi

      attr_reader :source, :start_pos, :end_pos
      
      def initialize(source, start_pos, end_pos)
        @source = source
        @start_pos = start_pos
        @end_pos = end_pos
      end

      def length
        end_pos - start_pos + 1
      end
      
      def code
        source.content[start_pos..end_pos]
      end
      
      # TODO should be lines as a range might span multiple lines
      def line(highlight = false)
        line = source.lines[line_num - 1].dup
        highlight ? line_head + ansi_format(code, [:red, :bold]) + line_tail : line
      end

      def line_num
        coordinate[0]
      end

      def column
        coordinate[1]
      end
      
      # all content that precedes the range in source
      def content_head
        source.content[0..(start_pos - 1)].to_s
      end
      
      # all content that succeeds the range in source
      def content_tail
        source.content[(end_pos + 1)..-1].to_s
      end
      
      # all content that precedes the range in the first line of the range in source
      def line_head
        line[0..(column - 2)].to_s
      end
      
      # all content that succeeds the range in the last line of the range in source
      def line_tail
        line[(column + length - 1)..-1].to_s
      end

      # excerpt from source, preceding and succeeding [Call.context_lines] lines
      def context
        @context ||= source.lines[line_num - Call.context_lines - 1, Call.context_lines].join +
                     line(true) + source.lines[line_num, Call.context_lines].join
      end
      
      def replace(value)
        @length = value.inspect.length
        @end_pos = start_pos + @length - 1
        reset!
      end
      
      def reset!
        @coordinate, @context = nil, nil
        @source = Source.new(@source.file)
      end
      
      protected

        def coordinate
          @coordinate ||= begin
            line_num, col = 1, 1
            source.lines.inject(0) do |sum, line|
              break if sum + line.length > start_pos
              line_num += 1
              col = start_pos - sum - line.length + 1
              sum += line.length
            end
            [line_num, col]
          end
        end
    end
  end
end