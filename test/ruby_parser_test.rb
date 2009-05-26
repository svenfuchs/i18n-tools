require File.dirname(__FILE__) + '/test_helper'

class RubyParserTest < Test::Unit::TestCase
  def test_sexp_filename
    filename = File.dirname(__FILE__) + '/fixtures/source_1.rb'
    sexp = I18n::RubyParser.new.parse(File.read(filename), filename)
    assert_equal filename, sexp.file
  end

  def test_sexp_source_positions
    assert_equal 2, 't(:foo)'.to_sexp.find_node(:lit).source_start_pos
    assert_equal 5, 't(:foo)'.to_sexp.find_node(:lit).source_end_pos
  end

  def test_sexp_source_symbol
    assert_equal ':foo', 't(:foo)'.to_sexp.find_node(:lit).source
  end

  def test_sexp_source_symbol_and_options
    assert_equal ':foo', 't(:foo, :bar => :baz)'.to_sexp.find_node(:lit).source
  end
  
  def test_sexp_source_symbol_with_double_quotes
    assert_equal ':"foo"', 't(:"foo")'.to_sexp.find_node(:lit).source
  end
  
  def test_sexp_source_symbol_with_double_quotes_and_options
    assert_equal ':"foo"', 't(:"foo", :bar => :baz)'.to_sexp.find_node(:lit).source
  end
  
  def test_sexp_source_symbol_with_single_quotes
    assert_equal ":'foo'", "t(:'foo')".to_sexp.find_node(:lit).source
  end
  
  def test_sexp_source_symbol_with_single_quotes_and_options
    assert_equal ":'foo'", "t(:'foo', :bar => :baz)".to_sexp.find_node(:lit).source
  end
  
  def test_sexp_source_string_with_double_quotes
    assert_equal '"foo"', 't("foo")'.to_sexp.find_node(:str).source
  end
  
  def test_sexp_source_string_with_double_quotes_and_options
    assert_equal '"foo"', 't("foo", :bar => :baz)'.to_sexp.find_node(:str).source
  end
  
  def test_sexp_source_string_with_single_quotes
    assert_equal "'foo'", "t('foo')".to_sexp.find_node(:str).source
  end
  
  def test_sexp_source_string_with_single_quotes_and_options
    assert_equal "'foo'", "t('foo', :bar => :baz)".to_sexp.find_node(:str).source
  end
end