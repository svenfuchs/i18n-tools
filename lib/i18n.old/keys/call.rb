module I18n
  module Keys
    class Call
      @@context_lines = 2

      class << self
        def context_lines
          @@context_lines
        end

        def context_lines=(num)
          @@context_lines = num
        end

        def from_sexp(sexp, file = nil)
          source = Source.new(file || sexp.file)
          new(source, key_from_sexp(sexp, source), scope_from_sexp(sexp, source))
        end
        
        def key_from_sexp(sexp, source)
          key = sexp.arglist[1]
          Argument.new(:key, key.to_sym, source, key.source_start_pos, key.source_end_pos)
        end
        
        def scope_from_sexp(sexp, source)
          return unless sexp.arglist[2] && sexp.arglist[2][0] == :hash
          options = sexp.arglist[2]
          options[1..-1].each_with_index do |node, ix|
            if node[0] == :lit && node[1] == :scope
              sexp = options[ix + 2].dup
              return Argument.new(:scope, eval(sexp.to_ruby), source, sexp.source_start_pos, sexp.source_end_pos)
            end
          end
        end
      end

      attr_reader :source, :key, :scope

      # track arguments: scope, default
      # extract position?
      def initialize(source, key, scope)
        @source = source
        @key = key
        @scope = scope
      end

      def replace!(replacement)
        source.replace(key.content_head + replacement.to_sym.inspect + key.content_tail)
        key.replace(replacement.to_sym)
      end

      def to_s
        "#{key}: #{source.file} [#{source.line_num}/#{source.column}]"
      end

      def ==(other)
        key == other.key and start_pos == other.start_pos and end_pos == other.end_pos
      end
    end
  end
end