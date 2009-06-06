require 'ripper'
require 'ruby'

class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    class << self
      def build(src)
        new(src).parse
      end
    end
      
    attr_reader :src, :filename
    
    def initialize(src, filename = nil, lineno = nil)
      @src = src || filename && File.read(filename)
      @filename = filename
      super
    end
    
    def on_program(statements)
      Ruby::Program.new(src, filename, statements)
    end

    def on_stmts_add(target, statement)
      target << statement
    end
    
    def on_stmts_new
      []
    end
    
    def on_void_stmt
      nil # what's this?
    end
    
    def on_ident(*args)
      value, position = *super[1..2]
      Ruby::Identifier.new(value, position.tap { |p| p[0] -= 1 }) # Ruby::Node expects zero-based positions
    end
    
    def on_kw(*args)
      value, position = *super[1..2]
      Ruby::Keyword.new(value, position.tap { |p| p[0] -= 1 })    # Ruby::Node expects zero-based positions
    end
    
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
    
    def on_int(*args)
      value, position = *super[1..2]
      Ruby::Integer.new(value, position.tap { |p| p[0] -= 1 })    # Ruby::Node expects zero-based positions
    end
    
    def on_float(*args)
      value, position = *super[1..2]
      Ruby::Float.new(value, position.tap { |p| p[0] -= 1 })      # Ruby::Node expects zero-based positions
    end
    
    def on_const(*args)
      value, position = *super[1..2]
      Ruby::Const.new(value, position.tap { |p| p[0] -= 1 })      # Ruby::Node expects zero-based positions
    end
    
    def on_class(const, super_class, body)
      Ruby::Class.new(const, super_class, body)
    end
    
    def on_body_stmt(statements, *something)
      Ruby::Body.new(statements.compact)
    end
    
    def on_def(identifier, params, body)
      Ruby::Method.new(identifier, params, body)
    end
    
    def on_const_ref(const)
      const # not sure what to do here
    end
    
    def on_assign(left, right)
      Ruby::Assignment.new(left, right)
    end
    
    def on_massign(left, right)
      Ruby::Assignment.new(left, right)
    end
    
    def on_mlhs_new
      Ruby::MultiAssignment.new(:left)
    end
    
    def on_mlhs_add(assignment, obj)
      assignment.tap { |a| a << obj }
    end
    
    def on_mlhs_paren(arg)
      arg.tap { |a| a.parentheses = true if a.respond_to?(:parentheses) }
    end
    
    def on_mrhs_new
      Ruby::MultiAssignment.new(:right)
    end
    
    def on_mrhs_new_from_args(args)
      Ruby::MultiAssignment.new(:right, args.values)
    end
    
    def on_mrhs_add(assignment, ref)
      assignment << ref
    end
    
    def on_mrhs_add_star(assignment, ref)
      assignment.tap { |a| a.star = true } << ref
    end
    
    def on_field(field)
      field # not sure what to do here
    end
    
    def on_var_ref(ref)
      ref # not sure what to do here
    end
    
    def on_var_field(field)
      field # not sure what to do here
    end
    
    def on_method_add_arg(call, args)
      call.tap { |call| call.arguments = args }
    end
    
    def on_method_add_block(call, block)
      call.tap { |call| call.block = block }
    end
    
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
    
    def on_arg_paren(args)
      args ||= Ruby::ArgsList.new
      args.tap { |args| args.parentheses = true }
    end
    
    def on_args_add_block(args, block)
      args # dunno, we'd probably add the block here? right now just skipping this node
    end
    
    def on_args_add(args, arg)
      args << arg 
    end
    
    def on_args_new
      Ruby::ArgsList.new
    end
    
    def on_symbol_literal(symbol)
      symbol.tap { |s| s.literal = true }
    end
    
    def on_symbol(identifier)
      Ruby::Symbol.new(identifier.token, identifier.position)
    end
    
    def on_dyna_symbol(arg)
      Ruby::DynaSymbol.new(arg)
    end
    
    def on_string_literal(string)
      string.tap { |s| s.literal = true }
    end
    
    def on_string_add(string, content)
      # string.quote = quote_from_source(content)
      string << content
    end
    
    def on_xstring_add(string, content)
      string << content
    end
    
    def on_xstring_new
      Ruby::String.new
    end
    
    def on_string_content
      Ruby::String.new
    end
    
    def on_tstring_content(string)
      value, position = *super[1..2]
      Ruby::StringContent.new(value, position.tap { |p| p[0] -= 1 }) # Ruby expects zero-based positions
    end

    def on_hash(assocs)
      Ruby::Hash.new(assocs)
    end
    
    def on_assoclist_from_args(args)
      args
    end
    
    def on_bare_assoc_hash(assocs)
      Ruby::Hash.new(assocs).tap { |hash| hash.bare = true }
    end
    
    def on_assoc_new(key, value)
      Ruby::Assoc.new(key, value)
    end
    
    def on_array(args_list)
      Ruby::Array.new(args_list)
    end
    
    def on_do_block(params, statements)
      Ruby::Block.new(statements, params)
    end
    
    def on_block_var(params, something)
      params
    end
    
    def on_paren(params)
      params.tap { |p| p.parentheses = true }
    end
    
    def on_params(*args)
      cmd, params, other, rest_param = super
      # params ||= other # blocks populate params, methods populate other, not sure why this is
      params << Ruby::RestParam.new(rest_param[1].token) if rest_param
      Ruby::ParamsList.new(params)
    end
    
    # def on_words_beg(*args)
    #   super.tap { |result| p result }
    # end
    # 
    # def on_lbrace(*args)
    #   super.tap { |result| p result }
    # end
    # 
    # def on_op(*args)
    #   super.tap { |result| p result }
    # end
    # 
    # def on_symbeg(*args)
    #   super.tap { |result| p result }
    # end
    # 
    # def on_tstring_beg(*args)
    #   super # [:@tstring_beg, "'", [1, 0]]
    #         # [:@tstring_beg, "%(", [1, 0]]
    # end
    # 
    # def on_qwords_beg(*args)
    #   super # [:@qwords_beg, "%w(", [1, 0]]
    # end
    #   
    # 
    # def on_lbracket(*args)
    #   super # [:@lbracket, "[", [1, 39]]
    # end
  end
end