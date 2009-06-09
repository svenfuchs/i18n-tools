class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Args
      def on_arg_paren(args)
        args ||= Ruby::ArgsList.new # will be nil when call has an empty arglist, e.g. I18n.t()

        pop_delim(:@rparen).tap { |r| args.rdelim = r if r }
        pop_delims(:@comma).tap { |s| args.separators = s.reverse unless s.empty? }
        pop_delim(:@lparen).tap { |l| args.ldelim = l if l }

        args
      end

      def on_args_add_block(args, block)
        args << Ruby::BlockArg.new(block, stack_ignore(:@rparen) { pop_delim(:@op) }) if block
        args
      end

      def on_args_add(args, arg)
        args << arg
        args
      end

      def on_args_new
        Ruby::ArgsList.new
      end
    end
  end
end