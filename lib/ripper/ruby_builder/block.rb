class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Block
      def on_body_stmt(statements, *something)
        Ruby::Body.new(statements.compact)
      end
    
      def on_method_add_arg(call, args)
        call.arguments = args
        call
      end

      def on_method_add_block(call, block)
        block.rdelim = pop_delim(:@kw, :value => 'end')
        block.ldelim = pop_delim(:@kw, :value => 'do')
        call.block = block
        call
      end

      def on_do_block(params, statements)
        Ruby::Block.new(statements, params)
      end

      def on_block_var(params, something)
        params
      end
    end
  end
end