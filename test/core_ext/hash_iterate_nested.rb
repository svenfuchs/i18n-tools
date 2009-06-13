require File.dirname(__FILE__) + '/../test_helper'
require 'core_ext/hash/iterate_nested'

class HashIterateNestedTest < Test::Unit::TestCase
  def test_hash_each_nested
    hash = { :foo => { :bar => { :baz => :baa, :bas => :bah }, :bor => { :boz => :boo, :bos => :boh } } }
    result = { :keys => [], :values => []}
    hash.each_nested do |keys, value|
      result[:keys] << keys
      result[:values] << value
    end
    assert_equal [[:foo, :bar, :baz], [:foo, :bar, :bas], [:foo, :bor, :boz], [:foo, :bor, :bos]], result[:keys]
    assert_equal [:baa, :bah, :boo, :boh], result[:values]
  end

  def test_hash_select_nested
    hash = { :foo => { :bar => { :baz => :baa, :bas => :bah }, :bor => { :boz => :boo, :bos => :boh } } }
    
    expected = hash
    result = hash.select_nested { |keys, value| keys.include?(:foo) }
    assert_equal expected, result

    expected = { :foo => { :bar => { :baz => :baa, :bas => :bah } } }
    result = hash.select_nested { |keys, value| keys.include?(:bar) }
    assert_equal expected, result

    expected = { :foo => { :bor => { :boz => :boo } } }
    result = hash.select_nested { |keys, value| keys.include?(:boz) }
    assert_equal expected, result
  end
end