require File.dirname(__FILE__) + '/../../test_helper'

require 'i18n/index/simple'
require 'yaml'

class I18nIndexKeyTest < Test::Unit::TestCase
  include I18n::Index
  
  define_method :"test matches? given no keys returns true" do
    assert Key.new(:foo).send(:matches?)
  end

  define_method :"test matches? given a literally matching key returns true" do
    assert Key.new(:foo).send(:matches?, :foo, :bar)
  end

  define_method :"test pattern with no wildcards" do
    assert_equal /^foo\.bar$/, Key.send(:pattern, :'foo.bar')
  end

  define_method :"test pattern with a dot separated wildcard at the beginning" do
    assert_equal /\.foo\.bar$/, Key.send(:pattern, :'*.foo.bar')
  end

  define_method :"test pattern with a dot separated wildcard at the end" do
    assert_equal /^foo\.bar\./, Key.send(:pattern, :'foo.bar.*')
  end

  define_method :"test pattern with a dot separated wildcard at the beginning and end" do
    assert_equal /\.foo\.bar\./, Key.send(:pattern, :'*.foo.bar.*')
  end
end