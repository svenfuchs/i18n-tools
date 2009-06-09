class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Args
      def on_arg_paren(args)
        args ||= Ruby::ArgsList.new

        rdelim = pop_delim(:@rparen)
        separators = pop_delims(:@comma).reverse
        
        if ldelim = pop_delim(:@lparen)
          args.position = ldelim.position
          args.whitespace = ldelim.whitespace
          args.ldelim = ldelim #.token
          args.rdelim = rdelim #.token if rdelim # rdelim.whitespace + 
          args.separators = separators
        end
        
        args
      end

      def on_args_add_block(args, block)
        if block
          ldelim = stack_ignore(:@rparen) { pop_delim(:@op) }
          args << Ruby::BlockArg.new(block, ldelim) # ldelim.position
        end
        args
      end

      def on_args_add(args, arg)
        args.position rescue args.position = arg.position
        args << arg
        args
      end

      def on_args_new
        Ruby::ArgsList.new
      end
    end
  end
end