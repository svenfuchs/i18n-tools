class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Call
      def on_command(identifier, args)
        Ruby::Call.new(nil, identifier, args)
      end

      def on_command_call(target, sep, identifier, args)
        Ruby::Call.new(target, identifier, args)
      end

      def on_call(target, sep, identifier)
        Ruby::Call.new(target, identifier)
      end

      def on_fcall(identifier)
        Ruby::Call.new(nil, identifier)
      end
    end
  end
end