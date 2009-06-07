class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Array
      def on_array(elements)
        separators = pop_delims(:@rbracket, :@comma, :@lbracket).reverse
        ldelim = separators.shift
        rdelim = separators.pop
        
        Ruby::Array.new(elements, ldelim.position.dup, pop_whitespace, ldelim, rdelim, separators)
      end
    end
  end
end

