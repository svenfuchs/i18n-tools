class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Array
      def on_array(elements)
        separators = pop_delims(:@rbracket, :@comma, :@lbracket).reverse
        ldelim = separators.shift
        rdelim = separators.pop

        Ruby::Array.new(elements.to_a, '', ldelim, rdelim, separators)
      end
      
      def on_qwords_new(*args)
        Ruby::Array.new(nil, '', pop_delim(:@qwords_beg))
      end
      
      def on_qwords_add(array, arg)
        tokens = pop_delims(:@words_sep)
        separators = tokens.select { |t| t.token =~ /^\s*$/ }
        rdelims = tokens - separators

        separators.each { |sep| array.separators << sep }
        array.rdelim = rdelims.first if rdelims

        array << arg
        array
      end
    end
  end
end

