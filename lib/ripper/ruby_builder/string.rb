class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module String
      def on_string_literal(string)
        string.rdelim = pop_delim(:@tstring_end)
        string
      end

      def on_string_add(string, content)
        string << content and string
      end

      def on_string_content
        Ruby::String.new(nil, pop_delim(:@tstring_beg))
      end

      def on_tstring_content(token)
        Ruby::StringContent.new(token, position)
      end
    end
  end
end