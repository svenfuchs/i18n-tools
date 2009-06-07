class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Symbol
      def on_symbol_literal(symbol)
        symbol
      end

      def on_symbol(identifier)
        Ruby::Symbol.new(identifier.token, pop_delim(:@symbeg))
      end

      def on_dyna_symbol(symbol)
        symbol.rdelim = pop_delim(:@tstring_end)
        symbol
      end

      def on_xstring_add(string, content)
        string.tap { |s| s << content }
      end

      def on_xstring_new
        Ruby::DynaSymbol.new(nil, pop_delim(:@symbeg))
      end
    end
  end
end