require File.dirname(__FILE__) + '/../../ansi'

module I18n
  module Keys
    class Occurence
      include Ansi

      @@context_lines = 2

      class << self
        def context_lines
          @@context_lines
        end

        def context_lines=(num)
          @@context_lines = num
        end

        def from_sexp(sexp, file = nil)
          new(sexp[1], file || sexp.file, sexp.source_start_pos, sexp.source_end_pos)
        end
      end

      attr_reader :key, :file, :start_pos, :end_pos

      def initialize(key, file, start_pos, end_pos)
        @key = key.to_sym
        @file = file
        @start_pos = start_pos
        @end_pos = end_pos
      end
      
      def replace!(replacement)
        replacement = replacement.to_sym.inspect
        content = content_head + replacement + content_tail
        @key = replacement.to_sym
        self.length = replacement.to_s.length
        File.open(file, 'w+') { |f| f.write(content) }
        @position, @lines, @context = nil, nil, nil
      end
      
      def content
        lines.join
      end

      def lines
        @lines ||= File.open(file, 'r') { |f| f.readlines }
      end

      def line(highlight = false)
        line = lines[line_num - 1].dup
        highlight ? line_head + ansi_format(original_key, [:red, :bold]) + line_tail : line
      end

      def line_num
        position[0]
      end

      def column
        position[1]
      end

      def length
        end_pos - start_pos + 1
      end
      
      def length=(length)
        @length = length
        @end_pos = start_pos + length - 1
      end
      
      def original_key
        line[column - 1, length]
      end
      
      def content_head
        content[0..(start_pos - 1)].to_s
      end
      
      def content_tail
        content[(end_pos + 1)..-1].to_s
      end
      
      def line_head
        line[0..(column - 2)].to_s
      end
      
      def line_tail
        line[(column + length - 1)..-1].to_s
      end

      def context
        @context ||=
          lines[line_num - self.class.context_lines - 1, self.class.context_lines].join +
          line(true) + lines[line_num, self.class.context_lines].join
      end

      def to_s
        "#{key}: #{file} [#{line_num}/#{column}]"
      end
      
      def ==(other)
        key == other.key and start_pos == other.start_pos and end_pos == other.end_pos
      end

      def position
        @position ||= begin
          line_num, col = 1, 1
          lines.inject(0) do |sum, line|
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