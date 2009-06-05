require File.dirname(__FILE__) + '/test_helper'

class RipperRubyBuilderArgumentsTest < Test::Unit::TestCase
  def build(src)
    Ripper::RubyBuilder.build(src)
  end
  
  def sexp(src)
    Ripper::SexpBuilder.new(src).parse
  end

  define_method :'test assignment: a = b' do
    src = 'a = b'
    assignment = build(src).statements.first
    assert_equal Ruby::Assignment, assignment.class
    assert_equal 'a', assignment.left.value
    assert_equal 'b', assignment.right.value
    assert_equal src, assignment.to_ruby
  end
  
  define_method :'test assignment: a, b = c' do
    src = 'a, b = c'
    assignment = build(src).statements.first
    assert_equal Ruby::Assignment, assignment.class
    assert_equal Ruby::MultiAssignment, assignment.left.class
    assert_equal 'a', assignment.left[0].value
    assert_equal 'b', assignment.left[1].value
    assert_equal 'c', assignment.right.value
    assert_equal src, assignment.to_ruby
  end
  
  define_method :'test assignment: a, b = c, d' do
    src = 'a, b = c, d'
    assignment = build(src).statements.first
    assert_equal Ruby::Assignment, assignment.class
    assert_equal Ruby::MultiAssignment, assignment.left.class
    assert_equal 'a', assignment.left[0].value
    assert_equal 'b', assignment.left[1].value
    assert_equal 'c', assignment.right[0].value
    assert_equal 'd', assignment.right[1].value
    assert_equal src, assignment.to_ruby
  end
  
  define_method :'test assignment: a, b = c, d' do
    src = 'a, b = *c'
    assignment = build(src).statements.first
    assert_equal Ruby::Assignment, assignment.class
    assert_equal Ruby::MultiAssignment, assignment.left.class
    assert_equal 'a', assignment.left[0].value
    assert_equal 'b', assignment.left[1].value
    assert assignment.right.star?
    assert_equal 'c', assignment.right[0].value
    assert_equal src, assignment.to_ruby
  end
end