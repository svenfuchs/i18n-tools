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
    
    include Block, Params, Call, String, Symbol, Hash, Array, Args, 
            Assignment, Operator, Scanner
    
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
        options = types.last.is_a?(::Hash) ? types.pop : {}
        max = options[:max]
        value = options[:value]
        tokens, ignored = [], []

        while !empty? && !(max && tokens.length >= max)
          if types.include?(last.type) && (value.nil? || last.value == value)
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
      target << statement #.tap { |s| s.parent = target }
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

    def on_kw(token)
      if %w(do end).include?(token)
        return push(super) 
      else
        Ruby::Keyword.new(token, position, pop_whitespace)
      end
    end

    def on_int(token)
      Ruby::Integer.new(token, position, pop_whitespace)
    end

    def on_float(token)
      Ruby::Float.new(token, position, pop_whitespace)
    end

    def on_const(token)
      Ruby::Const.new(token, position, pop_whitespace)
    end

    def on_class(const, super_class, body)
      Ruby::Class.new(const, super_class, body)
      end

    def on_def(identifier, params, body)
      Ruby::Method.new(identifier, params, body)
    end

    def on_const_ref(const)
      const # not sure what to do here
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

    def on_paren(params)
      params
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
      
      def pop_delim(type, options = {})
        pop_delims(type, options).first
      end
    
      def pop_delims(*types)
        options = types.last.is_a?(::Hash) ? types.pop : {}
        stack_ignore(*WHITESPACE) do 
          types.map { |type| pop(type, options).map { |token| build_token(token) } }.flatten.compact
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