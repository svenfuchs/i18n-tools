require File.dirname(__FILE__) + '/test_helper'

class RipperRubyBuilderCallsTest < Test::Unit::TestCase
  def build(code)
    Ripper::RubyBuilder.build(code)
  end
  
  def sexp(src)
    Ripper::SexpBuilder.new(src).parse
  end

  define_method :"test identifier on no target without arguments and without parantheses" do
    # i'm not sure this is correct ... we're skipping :var_ref in ruby_builder
    src = "t"
    program = build(src)
    identifier = program.statements.first
    
    assert_equal 't', identifier.value

    assert_equal program, identifier.parent
    assert_equal src, identifier.src
    assert_equal src, identifier.to_ruby
  end

  define_method :"test call on const target without arguments and without parantheses" do
    src = "I18n.t"
    program = build(src)
    call = program.statements.first
    
    assert_equal 't', call.identifier.value
    assert call.arguments.empty?
    assert !call.arguments.parentheses?
    
    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end

  define_method :"test call on const target without arguments and with parantheses" do
    src = "I18n.t()"
    program = build(src)
    call = program.statements.first
    
    assert_equal 't', call.identifier.value
    assert call.arguments.empty?
    assert call.arguments.parentheses?
    
    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end

  define_method :'test method call: I18n.t("foo") (const target, double-quoted string, parantheses)' do
    src = "I18n.t('foo')"
    program = build(src)
    call = program.statements.first
    arg = call.arguments.first
  
    assert_equal 't', call.identifier.value
    assert_equal 'I18n', call.target.value
    assert call.arguments.parentheses?
  
    assert_equal 'foo', arg.first.value

    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end
  
  define_method :'test method call: I18n.t "foo" (const target, double-quoted string, no parantheses)' do
    src = "I18n.t 'foo'"
    program = build(src)
    call = program.statements.first
    arg = call.arguments.first

    assert_equal 't', call.identifier.value
    assert_equal 'I18n', call.target.value
    assert !call.arguments.parentheses?
  
    assert_equal 'foo', arg.first.value

    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end
  
  define_method :"test two method calls: t('foo'); t 'bar' (no target)" do
    program = build("t('foo'); t 'bar'")
    calls = program.statements

    assert_equal 't', calls[0].identifier.value
    assert calls[0].arguments.parentheses?
    assert !calls[0].target
  
    assert_equal 't', calls[1].identifier.value
    assert !calls[1].arguments.parentheses?
    assert !calls[1].target
  end
  
  define_method :"test call on no target without arguments but parantheses" do
    src = "t()"
    program = build(src)
    call = program.statements.first
  
    assert_equal 't', call.identifier.value
    assert !call.target
    assert call.arguments.parentheses?

    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end
  
  define_method :"test call on no target without arguments but a block" do # how to fucking handle whitespace
    src = "t do |a, b, *c|\nfoo\nend"
    program = build(src)
    call = program.statements.first

    assert_equal 't', call.identifier.value
    assert !call.target
    assert_equal Ruby::Block, call.block.class

    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end
  
  define_method :"test call on no target without arguments but a block" do # how to fucking handle whitespace
    src = "t do |(a, b), *c|\nfoo\nend"
    program = build(src)
    call = program.statements.first
  
    assert_equal 't', call.identifier.value
    assert !call.target
    assert_equal Ruby::Block, call.block.class
  
    assert_equal program, call.parent
    assert_equal src, call.src
    assert_equal src, call.to_ruby
  end
  
  # define_method :"test call on no target with a block var" do
  #   src = "t(:foo, &block)"
  #   program = build(src)
  #   call = program.statements.first
  # end
end