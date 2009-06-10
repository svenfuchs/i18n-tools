class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Call
      def on_command(identifier, args)
        Ruby::Call.new(nil, nil, identifier, args)
      end

      def on_command_call(target, separator, identifier, args)
        separator = pop_delim(:@period)
        Ruby::Call.new(target, separator, identifier, args)
      end

      def on_call(target, separator, identifier)
        separator = pop_delim(:@period)
        Ruby::Call.new(target, separator, identifier)
      end

      def on_fcall(identifier)
        Ruby::Call.new(nil, nil, identifier)
      end
    end
  end
end