class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Symbol
      def on_symbol_literal(symbol)
        symbol
      end

      def on_symbol(identifier)
        ldelim = pop_delim(:@symbeg)
        Ruby::Symbol.new(identifier.token, ldelim)
      end

      def on_dyna_symbol(symbol)
        symbol.rdelim = pop_delim(:@tstring_end)
        symbol
      end

      def on_xstring_add(string, content)
        string.tap { |s| s << content }
      end

      def on_xstring_new
        ldelim = pop_delim(:@symbeg)
        Ruby::DynaSymbol.new(ldelim)
      end
    end
  end
end