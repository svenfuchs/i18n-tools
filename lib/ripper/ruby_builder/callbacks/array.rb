class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Array
      # elements and separators are collected in on_args_add
      # confusingly ripper throws the same events
      
      def on_array(elements)
        rdelim, ldelim = pop_delims(:@rbracket, :@lbracket)
        Ruby::Array.new(elements.to_a, ldelim, rdelim, elements.separators)
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

