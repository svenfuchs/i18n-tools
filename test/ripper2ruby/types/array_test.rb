require File.dirname(__FILE__) + '/../test_helper'

class RipperToRubyArrayTest < Test::Unit::TestCase
  include TestRubyBuilderHelper
  
  define_method :'test an array with a symbol: [:foo]' do
    src = '[:foo]'
    program = build(src)
    array = program.statements.first
  
    assert_equal Ruby::Array, array.class
    assert_equal :foo, array.first.value
  
    assert_equal program, array.parent
    assert_equal array, array.first.parent
  
    assert_equal src, array.root.src
    assert_equal src, array.first.root.src
    assert_equal src, array.to_ruby
  
    assert_equal [0, 0], array.position
    assert_equal 0, array.row
    assert_equal 0, array.column
    assert_equal 6, array.length
  end
  
  define_method :'test array length: with and without whitespace' do
    assert_equal 6,  array("[:foo]").length
    assert_equal 8,  array("[:foo  ]").length
    assert_equal 8,  array("[  :foo]").length
    assert_equal 10, array("[  :foo  ]").length
      
    assert_equal 6,  array("[:foo]").length(true)
    assert_equal 8,  array("[:foo  ]").length(true)
    assert_equal 8,  array("[  :foo]").length(true)
    assert_equal 10, array("[  :foo  ]").length(true)
    
    assert_equal 10, array("[\n :foo \n]").length
    assert_equal 10, array("[\n :foo \n]").length(true)
    assert_equal 10, array("  [\n :foo \n]").length
    assert_equal 12, array("  [\n :foo \n]").length(true)

    assert_equal 20,  array("[:foo,  :bar,  :baz]").length
    assert_equal 20,  array("[:foo , :bar , :baz]").length
    assert_equal 20,  array("[:foo  ,:bar  ,:baz]").length
  end
end