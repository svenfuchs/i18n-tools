class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Array
      def on_array(elements)
        separators = pop_delims(:@rbracket, :@comma, :@lbracket).reverse
        ldelim = separators.shift
        rdelim = separators.pop

        Ruby::Array.new(elements.to_a, ldelim, rdelim, separators)
      end
      
      def on_qwords_new(*args)
        Ruby::Array.new(nil, pop_delim(:@qwords_beg))
      end
      
      def on_qwords_add(array, arg)
        tokens = pop_delims(:@words_sep)

        array.separators += tokens.select { |t| t.token =~ /^\s*$/ }
        array.rdelim = (tokens - array.separators).first
        array << arg
        array
      end
    end
  end
end

