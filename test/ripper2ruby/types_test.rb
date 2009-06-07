require File.dirname(__FILE__) + '/test_helper'

class RipperToRubyTypesTest < Test::Unit::TestCase
  def build(code)
    Ripper::RubyBuilder.build(code)
  end

  def sexp(src)
    Ripper::SexpBuilder.new(src).parse
  end

  @@space = "  \n  "

  define_method :'test a const: I18n' do
    src = @@space + 'I18n'
    program = build(src)
    const = program.statements.first
  
    assert_equal program, const.parent
    assert_equal Ruby::Const, const.class
    assert_equal 'I18n', const.token
    assert_equal 'I18n', const.to_ruby
  
    assert_equal src, const.root.src
  
    assert_equal [1, 2], const.position
    assert_equal 1, const.row
    assert_equal 2, const.column
    assert_equal 4, const.length
  end
  
  define_method :'test an integer: 1' do
    src = @@space + '1'
    program = build(src)
    int = program.statements.first
  
    assert_equal program, int.parent
    assert_equal Ruby::Integer, int.class
    assert_equal 1, int.value
    assert_equal '1', int.to_ruby
  
    assert_equal src, int.root.src
  
    assert_equal [1, 2], int.position
    assert_equal 1, int.row
    assert_equal 2, int.column
    assert_equal 1, int.length
  end
  
  define_method :'test a double-quoted string: "foo"' do
    src = @@space + '"foo"'
    program = build(src)
    string = program.statements.first
  
    assert_equal Ruby::String, string.class
    assert_equal 'foo', string.value
    assert_equal '"foo"', string.to_ruby
  
    assert_equal program, string.parent
    assert_equal string, string.first.parent
  
    assert_equal src, string.root.src
    assert_equal src, string.first.root.src
  
    assert_equal [1, 2], string.position
    assert_equal 1, string.row
    assert_equal 2, string.column
    assert_equal 5, string.length
  end
  
  define_method :"test a single-quoted string: 'foo'" do
    src = @@space + "'foo'"
    program = build(src)
    string = program.statements.first
  
    assert_equal Ruby::String, string.class
    assert_equal 'foo', string.value
    assert_equal "'foo'", string.to_ruby
  
    assert_equal [1, 2], string.position
    assert_equal 1, string.row
    assert_equal 2, string.column
    assert_equal 5, string.length
  end
  
  define_method :'test an empty string: ""' do
    src = @@space + '""'
    program = build(src)
    string = program.statements.first
  
    assert_equal Ruby::String, string.class
    assert_equal '', string.value
    assert_equal '""', string.to_ruby
  
    # WTF ripper doesn't seem to pass positions for empty strings and stuff. now what?
    # assert_equal [1, 2], string.position
    # assert_equal 1, string.row
    # assert_equal 2, string.column
    # assert_equal 5, string.length
  end
  
  define_method :"test a symbol: :foo" do
    src = @@space + ":foo"
    program = build(src)
    symbol = program.statements.first
  
    assert_equal Ruby::Symbol, symbol.class
    assert_equal :foo, symbol.value
  
    assert_equal program, symbol.parent
    assert_equal ":foo", symbol.to_ruby
  
    assert_equal [1, 2], symbol.position
    assert_equal 1, symbol.row
    assert_equal 2, symbol.column
    assert_equal 4, symbol.length
  end

  define_method :"test a single-quoted symbol: :'foo'" do
    src = @@space + ":'foo'"
    program = build(src)
    symbol = program.statements.first

    assert_equal Ruby::DynaSymbol, symbol.class
    assert_equal :foo, symbol.value

    assert_equal program, symbol.parent
    assert_equal src, symbol.root.src

    assert_equal ":'foo'", symbol.to_ruby

    assert_equal [1, 2], symbol.position
    assert_equal 1, symbol.row
    assert_equal 2, symbol.column
    assert_equal 6, symbol.length
  end

  define_method :'test a double-quoted symbol: :"foo"' do
    src = @@space + ':"foo"'
    program = build(src)
    symbol = program.statements.first
  
    assert_equal Ruby::DynaSymbol, symbol.class
    assert_equal :foo, symbol.value
    assert_equal ':"foo"', symbol.to_ruby
  
    assert_equal [1, 2], symbol.position
    assert_equal 1, symbol.row
    assert_equal 2, symbol.column
    assert_equal 6, symbol.length
  end
  
  define_method :"test keyword: nil" do
    src = @@space + 'nil'
    program = build(src)
    keyword = program.statements.first
  
    assert_equal Ruby::Keyword, keyword.class
    assert_equal nil, keyword.value
  
    assert_equal program, keyword.parent
    assert_equal src, keyword.root.src
  
    assert_equal 'nil', keyword.to_ruby
  
    assert_equal [1, 2], keyword.position
    assert_equal 1, keyword.row
    assert_equal 2, keyword.column
    assert_equal 3, keyword.length
  end
  
  define_method :"test keyword: true" do
    src = @@space + 'true'
    program = build(src)
    keyword = program.statements.first
  
    assert_equal Ruby::Keyword, keyword.class
    assert_equal true, keyword.value
  
    assert_equal program, keyword.parent
    assert_equal src, keyword.root.src
  
    assert_equal 'true', keyword.to_ruby
  
    assert_equal [1, 2], keyword.position
    assert_equal 1, keyword.row
    assert_equal 2, keyword.column
    assert_equal 4, keyword.length
  end
  
  define_method :"test keyword: false" do
    src = @@space + 'false'
    program = build(src)
    keyword = program.statements.first
  
    assert_equal Ruby::Keyword, keyword.class
    assert_equal false, keyword.value
  
    assert_equal program, keyword.parent
    assert_equal src, keyword.root.src
  
    assert_equal 'false', keyword.to_ruby
  
    assert_equal [1, 2], keyword.position
    assert_equal 1, keyword.row
    assert_equal 2, keyword.column
    assert_equal 5, keyword.length
  end
  
  define_method :"test keyword: __FILE__" do
    src = @@space + '__FILE__'
    program = build(src)
    keyword = program.statements.first
  
    assert_equal Ruby::Keyword, keyword.class
    assert_equal '__FILE__', keyword.value
  
    assert_equal program, keyword.parent
    assert_equal src, keyword.root.src
  
    assert_equal '__FILE__', keyword.to_ruby
  
    assert_equal [1, 2], keyword.position
    assert_equal 1, keyword.row
    assert_equal 2, keyword.column
    assert_equal 8, keyword.length
  end
  
  define_method :"test keyword: __LINE__" do
    src = @@space + '__LINE__'
    program = build(src)
    keyword = program.statements.first
  
    assert_equal Ruby::Keyword, keyword.class
    assert_equal '__LINE__', keyword.value
  
    assert_equal program, keyword.parent
    assert_equal src, keyword.root.src
  
    assert_equal '__LINE__', keyword.to_ruby
  
    assert_equal [1, 2], keyword.position
    assert_equal 1, keyword.row
    assert_equal 2, keyword.column
    assert_equal 8, keyword.length
  end
  
  def test_class
    src = "class Foo < Bar\nfoo\nend"
    program = build(@@space + src)
    const = program.statements.first
  
    assert_equal program, const.parent
    assert_equal const, const.super_class.parent
    assert_equal const, const.body.parent
  
    assert_equal 'Foo', const.token
    assert_equal 'Bar', const.super_class.token
    assert_equal 'foo', const.body.statements.first.token
  
    assert_equal src, const.to_ruby

    assert_equal [1, 2], const.position
  end
  
  # def test_method
  #   src = "def foo(a = nil, &block)\nbar\nend"
  #   program = build(src)
  #   method = program.statements.first
  # 
  #   assert_equal program, method.parent
  #   assert_equal method, method.identifier.parent
  #   assert_equal method, method.params.parent
  #   assert_equal method, method.body.parent
  # 
  #   assert_equal 'foo', method.identifier.value
  #   assert_equal 'Bar', method.params.first.value
  #   assert_equal 'bar', method.body.statements.first.value
  # 
  #   assert_equal src, const.to_ruby
  # end
end