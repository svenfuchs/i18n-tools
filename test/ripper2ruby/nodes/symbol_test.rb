require File.dirname(__FILE__) + '/../test_helper'

class RipperToRubySymbolTest < Test::Unit::TestCase
  include TestRubyBuilderHelper

  def test_symbol
    src = "    \n  \n :foo"
    symbol = node(src, Ruby::Symbol)

    assert_equal ':', symbol.ldelim.token
    assert_equal 'foo', symbol.token
    assert_equal "    \n  \n ", symbol.ldelim.whitespace
    assert_equal [2, 1], symbol.position
  
    assert_equal 4, symbol.length
    assert_equal 9, symbol.src_pos
    assert_equal :foo, symbol.value
    assert_equal ':foo', symbol.src
    assert_equal ':foo', symbol.to_ruby
  
    assert_equal 13, symbol.length(true)
    assert_equal 0, symbol.src_pos(true)
    assert_equal src, symbol.src(true)
  end

  def test_single_quoted_dyna_symbol
    src = "    \n  \n :'foo'"
    symbol = node(src, Ruby::DynaSymbol)
  
    assert_equal :foo, symbol.value
    assert_equal ":'", symbol.ldelim.token
    assert_equal "'", symbol.rdelim.token
    assert_equal "    \n  \n ", symbol.ldelim.whitespace
    assert_equal [2, 1], symbol.position
  
    assert_equal 6, symbol.length
    assert_equal 9, symbol.src_pos
    assert_equal ":'foo'", symbol.src
    assert_equal ":'foo'", symbol.to_ruby
  
    assert_equal 15, symbol.length(true)
    assert_equal 0, symbol.src_pos(true)
    assert_equal src, symbol.src(true)
  end
end