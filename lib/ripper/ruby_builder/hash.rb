class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Hash
      def on_hash(assocs)
        separators = pop_delims(:@rbrace, :@comma, :@lbrace).reverse
        ldelim = separators.shift
        rdelim = separators.pop

        Ruby::Hash.new(assocs, ldelim.position.dup, ldelim, rdelim, separators)
      end

      def on_assoclist_from_args(args)
        args
      end

      def on_bare_assoc_hash(assocs)
        separators = pop_delims(:@comma).reverse
        Ruby::Hash.new(assocs, nil, nil, nil, separators)
      end

      def on_assoc_new(key, value)
        stack_ignore(:@rbrace, :@comma) do
          assoc = Ruby::Assoc.new(key, value, pop_delim(:@op))
        end
      end
    end
  end
end

