class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Operator
      def on_unary(*args)
        Ruby::Unary.new(*args)
      end

      def on_binary(*args)
        left, type, right = *args
        Ruby::Binary.new(type, left, right)
      end

      def on_ifop(*args)
        Ruby::IfOp.new(*args)
      end
    end
  end
end