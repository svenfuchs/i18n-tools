require File.dirname(__FILE__) + '/test_helper'

class RipperRubyBuilderArgumentsTest < Test::Unit::TestCase
  def build(code)
    Ripper::RubyBuilder.build(code)
  end

  def arguments(code)
    Ripper::RubyBuilder.new(code).parse.statements.first.arguments
  end

  define_method :'test method call: t("foo") (double-quoted string)' do
    src = 't("foo")'
    program = build(src)
    call = program.statements.first
    args = call.arguments
    string = args.first

    assert_equal 'foo', string.first.value
    
    assert_equal call, args.parent
    assert_equal args, string.parent
    assert_equal src, string.root.src
  end
  
  define_method :"test method call: t('foo') (single-quoted string)" do
    string = arguments("t('foo')").first
    assert_equal 'foo', string.first.value
  end
  
  define_method :"test method call: t(:foo) (symbol)" do
    symbol = arguments("t(:foo)").first
    assert_equal :foo, symbol.value
  end
  
  define_method :'test method call: t(:"foo") (double-quoted symbol)' do
    symbol = arguments('t(:"foo")').first
    assert_equal :foo, symbol.value
  end
  
  define_method :"test method call: t(:'foo') (single-quoted symbol)" do
    symbol = arguments("t(:'foo')").first
    assert_equal :foo, symbol.value
  end
  
  define_method :"test method call: t 'foo' (string, no parantheses)" do
    program = build("t 'foo'")
    args = program.statements.first.arguments
    string = args.first

    assert_equal 'foo', string.value

    assert_equal Ruby::Call, args.parent.class
    assert_equal args, string.parent
  end
  
  define_method :"test method call: t('foo', 'bar') (two strings)" do
    args = arguments("t('foo', 'bar')")
    assert_equal 'foo', args[0].value
    assert_equal 'bar', args[1].value
  end

  define_method :"test method call: t(:foo => :bar, :baz => :buz) (bare hash)" do
    src = "t(:foo => :bar, :baz => :buz)"
    call = build(src).statements.first
    hash = call.arguments.first

    assert hash.bare?
    assert_equal :foo, hash.assocs[0].key.value
    assert_equal :bar, hash.assocs[0].value.value
    assert_equal :baz, hash.assocs[1].key.value
    assert_equal :buz, hash.assocs[1].value.value
    
    assert_equal src, call.to_ruby
  end

  define_method :"test method call: t({ :foo => :bar, :baz => :buz }) (hash)" do
    src = "t({ :foo => :bar, :baz => :buz })"
    call = build(src).statements.first
    hash = call.arguments.first

    assert !hash.bare?
    assert_equal :foo, hash.assocs[0].key.value
    assert_equal :bar, hash.assocs[0].value.value
    assert_equal :baz, hash.assocs[1].key.value
    assert_equal :buz, hash.assocs[1].value.value

    assert_equal src, call.to_ruby
  end

  define_method :"test method call: t([:foo, :bar]) (array)" do
    src = "t([:foo, :bar, :baz])"
    call = build(src).statements.first
    array = call.arguments.first
    
    assert_equal :foo, array[0].value
    assert_equal :bar, array[1].value
    assert_equal :baz, array[2].value

    assert_equal src, call.to_ruby
  end
  
  define_method :"test method call: t(nil) (keyword)" do
    src = "t(nil)"
    call = build(src).statements.first
    kw = call.arguments.first
    
    assert_equal nil, kw.value
    assert_equal src, call.to_ruby
  end
  
  define_method :"test method call: t(1) (integer)" do
    src = "t(1)"
    call = build(src).statements.first
    integer = call.arguments.first
    
    assert_equal 1, integer.value
    assert_equal src, call.to_ruby
  end
  
  define_method :"test method call: t(1) (float)" do
    src = "t(1.1)"
    call = build(src).statements.first
    float = call.arguments.first
    
    assert_equal 1.1, float.value
    assert_equal src, call.to_ruby
  end
end