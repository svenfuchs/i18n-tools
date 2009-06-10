class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Args
      def on_arg_paren(args)
        args ||= Ruby::ArgsList.new # will be nil when call has an empty arglist, e.g. I18n.t()

        pop_delim(:@rparen).tap { |r| args.rdelim = r if r }
        pop_delim(:@lparen).tap { |l| args.ldelim = l if l }

        args
      end

      def on_args_add_block(args, block)
        rdelim = pop_delim(:@rparen)
        operator = pop_delim(:@op, :value => '&')
        separators = pop_delims(:@comma)

        args << Ruby::BlockArg.new(block, operator) if block
        args.separators += separators if separators
        args.rdelim = rdelim if rdelim
        args
      end

      def on_args_add(args, arg)
        pop_delims(:@comma).tap { |s| args.separators += s.reverse }
        args << arg
        args
      end

      def on_args_new
        Ruby::ArgsList.new
      end
    end
  end
end