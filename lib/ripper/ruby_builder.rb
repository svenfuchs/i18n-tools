require 'ripper'
require 'ruby'

Dir[File.dirname(__FILE__) + '/ruby_builder/*.rb'].each { |file| require file }

class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    class << self
      def build(src)
        new(src).parse
      end
    end
    
    WHITESPACE = [:@sp, :@nl, :@ignored_nl]
    
    include String, Symbol, Hash, Array, Args, Operator, Scanner
    
    class Token
      attr_accessor :type, :value, :whitespace, :row, :column

      def initialize(type, value = nil, position = nil)
        @type = type
        @value = value
        @whitespace = ''
        if position
          @row    = position[0] - 1
          @column = position[1]
        end
      end
      
      def position
        [row, column]
      end
      
      def whitespace?
        WHITESPACE.include?(type)
      end
      
      def to_sexp
        [type, value, [row + 1, column]]
      end
    end
      
    class Stack < ::Array
      def initialize
        @ignore_stack = []
      end
      
      def push(token)
        while !token.whitespace? && last && last.whitespace?
          token.whitespace = _pop.value + token.whitespace
        end
        self << token
      end
      
      alias :_pop :pop
      def pop(*types)
        tokens, ignored = [], []
        while !empty?
          if types.include?(last.type)
            tokens << super()
          elsif ignore?(last.type)
            ignored << super()
          else
            break
          end
        end
        ignored.reverse.each { |token| push(token) }
        tokens
      end
      
      def ignore?(type)
        @ignore_stack.flatten.include?(type)
      end
      
      def ignore_types(*types)
        @ignore_stack.push(types)
        result = yield
        @ignore_stack.pop
        result
      end
    end

    attr_reader :src, :filename, :stack

    def initialize(src, filename = nil, lineno = nil)
      @src = src || filename && File.read(filename)
      @filename = filename
      @whitespace = ''
      @stack = []
      @_stack_ignore_stack = [[]]
      @stack = Stack.new
      super
    end
    
    def position
      [lineno - 1, column]
    end

    def push(sexp)
      stack.push(Token.new(*sexp))
    end
    
    def whitespace?(type)
      WHITESPACE.include?(type)
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

    def on_ident(token)
      Ruby::Identifier.new(token, position, pop_whitespace)
    end

    def on_kw(*args)
      value, position = *super[1..2]
      Ruby::Keyword.new(value, position.tap { |p| p[0] -= 1 })    # Ruby::Node expects zero-based rows
    end

    def on_int(*args)
      value, position = *super[1..2]
      Ruby::Integer.new(value, position.tap { |p| p[0] -= 1 })    # Ruby::Node expects zero-based rows
    end

    def on_float(*args)
      value, position = *super[1..2]
      Ruby::Float.new(value, position.tap { |p| p[0] -= 1 })      # Ruby::Node expects zero-based rows
    end

    def on_const(*args)
      value, position = *super[1..2]
      Ruby::Const.new(value, position.tap { |p| p[0] -= 1 })      # Ruby::Node expects zero-based rows
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
      arg #.tap { |a| a.parentheses = true if a.respond_to?(:parentheses) }
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

    def on_do_block(params, statements)
      Ruby::Block.new(statements, params)
    end

    def on_block_var(params, something)
      params
    end

    def on_paren(params)
      params #.tap { |p| p.parentheses = true }
    end

    def on_params(*args)
      cmd, params, other, rest_param = super
      # params ||= other # blocks populate params, methods populate other, not sure why this is
      params << Ruby::RestParam.new(rest_param[1].token) if rest_param
      Ruby::ParamsList.new(params)
    end
    
    protected
    
      def build_identifier(token)
      end
    
      def build_token(token)
        Ruby::Token.new(token.value, token.position, token.whitespace) if token # , pop_whitespace
      end
      
      def pop(*types)
        stack.pop(*types)
      end
      
      def pop_delim(type)
        pop_delims(type).first
      end
    
      def pop_delims(*types)
        stack_ignore(*WHITESPACE) do 
          types.map { |type| pop(type).map { |token| build_token(token) } }.flatten.compact
        end
      end
      
      def pop_whitespace
        pop(*WHITESPACE).reverse.map { |token| token.value }.join
      end
    
      def stack_ignore(*types, &block)
        stack.ignore_types(*types, &block)
      end
  end
end