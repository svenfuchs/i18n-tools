require File.dirname(__FILE__) + '/../test_helper'

require 'i18n/ruby/translate_call'
# require 'yaml'

class I18nKeyTest < Test::Unit::TestCase
  include Ruby
  
  attr_reader :pre, :post
  def setup
    @pre = "a\nb\n"
    @post = "\nc\nd"
  end
  
  def args(src)
    program = Ripper::RubyBuilder.new(src).parse
    program.statements[2].arguments.to_translate_args_list
  end
  
  define_method :"test: replace :foo with :fuh in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo], [:fuh])
    assert_equal "(:baz, :scope => [:fuh, :bar])", args.to_ruby
    assert_equal pre + "t(:baz, :scope => [:fuh, :bar])" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar] with [:fuh, :bah] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar], [:fuh, :bah])
    assert_equal "(:baz, :scope => [:fuh, :bah])", args.to_ruby
    assert_equal pre + "t(:baz, :scope => [:fuh, :bah])" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar] with [:fuh] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar], [:fuh])
    assert_equal "(:baz, :scope => [:fuh])", args.to_ruby
    assert_equal pre + "t(:baz, :scope => [:fuh])" + post, args.src
  end
  
  define_method :"test: replace [:foo] with [:foo, :fuh] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo], [:foo, :fuh])
    assert_equal "(:baz, :scope => [:foo, :fuh, :bar])", args.to_ruby
    assert_equal pre + "t(:baz, :scope => [:foo, :fuh, :bar])" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar, :baz] with [:foo] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar, :baz], [:foo])
    assert_equal "(:foo)", args.to_ruby
    assert_equal pre + "t(:foo)" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar, :baz] with [:foo, :bar] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar, :baz], [:foo, :bar])
    assert_equal "(:bar, :scope => [:foo])", args.to_ruby
    assert_equal pre + "t(:bar, :scope => [:foo])" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar, :baz] with [:foo, :bar, :buz] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar, :baz], [:foo, :bar, :buz])
    assert_equal "(:buz, :scope => [:foo, :bar])", args.to_ruby
    assert_equal pre + "t(:buz, :scope => [:foo, :bar])" + post, args.src
  end
  
  define_method :"test: replace [:foo, :bar, :baz] with [:foo, :bar, :baz, :buz] in (:baz, :scope => [:foo, :bar])" do
    args = args(pre + "t(:baz, :scope => [:'foo', :bar])" + post)
    args.replace!([:foo, :bar, :baz], [:foo, :bar, :baz, :buz])
    assert_equal "(:buz, :scope => [:foo, :bar, :baz])", args.to_ruby
    assert_equal pre + "t(:buz, :scope => [:foo, :bar, :baz])" + post, args.src
  end
end
