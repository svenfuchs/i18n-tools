class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Args
      def on_arg_paren(args)
        args || Ruby::ArgsList.new
        # args.tap { |args| args.parentheses = true }
      end

      def on_args_add_block(args, block)
        args # dunno, we'd probably add the block here? right now just skipping this node
      end

      def on_args_add(args, arg)
        # separator = pop_delim(:@comma)
        # args.separators << separator if separator
        args << arg
      end

      def on_args_new
        Ruby::ArgsList.new
      end
    end
  end
end