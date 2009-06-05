require 'rubygems'
require 'sexp_processor'
require 'ruby_parser'

# monkey patch galore, adds the ability to inspect the original source code
# that a :lit or :str sexp was parsed from

RubyLexer.class_eval do
  attr_accessor :source_start_pos, :source_end_pos

  def reset_source_positions!
    self.source_start_pos, self.source_end_pos = nil, nil, nil
  end
end

module I18n
  class RubyParser < RubyParser
    def s(*args)
      result = super

      result.full_source = lexer.src.string.dup
      result.source_start_pos = lexer.source_start_pos
      result.source_end_pos = lexer.source_end_pos || lexer.src.pos
      lexer.reset_source_positions!

      result
    end

    def _reduce_283(val, _values, result)
      # if val[1] && val[1][0] == :array
      #   p val, _values, result
      # end
      super
    end

    # def _reduce_261(val, _values, result)
    #     p val, _values, result
    #     p '-----------'
    #   # lexer.source_start_pos = lexer.src.pos - lexer.yacc_value.size - 1
    #   # result = s(:array, val[0])
    #   # result
    #   result = super
    #   # if result.first == :array
    #   #   p val, _values, result
    #   #   p '-----------'
    #   # end
    #   result
    # end

    # :tSYMBOL
    def _reduce_380(val, _values, result)
      lexer.source_start_pos = lexer.src.pos - lexer.yacc_value.size - 1
      lexer.source_end_pos = lexer.src.pos - 1
      super
    end

    # :tSTRING
    def _reduce_386(val, _values, result)
      lexer.source_start_pos = lexer.src.pos - lexer.yacc_value.size - 2
      lexer.source_end_pos = lexer.src.pos - 1
      super
    end
  
    # :tSYMBEG
    def _reduce_403(val, _values, result)
      lexer.source_start_pos = lexer.src.pos - lexer.yacc_value.size - 2
      super
    end
  
    def _reduce_418(val, _values, result)
      result = super
      result.source_start_pos = val[1].source_start_pos
      result.source_end_pos = val[1].source_end_pos
      result.full_source = val[1].full_source
      result
    end
  end
end

