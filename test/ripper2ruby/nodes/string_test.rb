require File.dirname(__FILE__) + '/../test_helper'

class RipperToRubyStringTest < Test::Unit::TestCase
  include TestRubyBuilderHelper

  def test_single_quoted_string
    src = "    \n  \n 'foo'"
    string = node(src, Ruby::String)

    assert_equal 'foo', string.value
    assert_equal "    \n  \n ", string.whitespace
    assert_equal [2, 1], string.position
    
    assert_equal "'", string.ldelim
    assert_equal "'", string.rdelim

    assert_equal 5, string.length
    assert_equal 9, string.src_pos
    assert_equal "'foo'", string.src
    assert_equal "'foo'", string.to_ruby
    
    assert_equal 14, string.length(true)
    assert_equal 0, string.src_pos(true)
    assert_equal src, string.src(true)
  end

  def test_double_quoted_string
    src = "    \n  \n \"foo\""
    string = node(src, Ruby::String)
  
    assert_equal 'foo', string.value
    assert_equal "    \n  \n ", string.whitespace
    assert_equal [2, 1], string.position
    
    assert_equal "\"", string.ldelim
    assert_equal "\"", string.rdelim
  
    assert_equal 5, string.length
    assert_equal 9, string.src_pos
    assert_equal "\"foo\"", string.src
    assert_equal "\"foo\"", string.to_ruby
    
    assert_equal 14, string.length(true)
    assert_equal 0, string.src_pos(true)
    assert_equal src, string.src(true)
  end
  
  def test_percent_parens_delimited_string
    src = "    \n  \n %(foo)"
    string = node(src, Ruby::String)
  
    assert_equal 'foo', string.value
    assert_equal "    \n  \n ", string.whitespace
    assert_equal [2, 1], string.position
    
    assert_equal '%(', string.ldelim
    assert_equal ')', string.rdelim
    
    assert_equal 6, string.length
    assert_equal 9, string.src_pos
    assert_equal "%(foo)", string.src
    assert_equal "%(foo)", string.to_ruby
    
    assert_equal 15, string.length(true)
    assert_equal 0, string.src_pos(true)
    assert_equal src, string.src(true)
  end
  
  def test_percent_dot_delimited_string
    src = "    \n  \n %.foo."
    string = node(src, Ruby::String)
  
    assert_equal 'foo', string.value
    assert_equal "    \n  \n ", string.whitespace
    assert_equal [2, 1], string.position
    
    assert_equal '%.', string.ldelim
    assert_equal '.', string.rdelim
    
    assert_equal 6, string.length
    assert_equal 9, string.src_pos
    assert_equal "%.foo.", string.src
    assert_equal "%.foo.", string.to_ruby
    
    assert_equal 15, string.length(true)
    assert_equal 0, string.src_pos(true)
    assert_equal src, string.src(true)
  end
end