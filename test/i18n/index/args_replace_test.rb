require File.dirname(__FILE__) + '/../../test_helper'
require 'i18n/project'

class I18nArgsReplaceTest < Test::Unit::TestCase
  include Ruby

  def init(src)
    @code = Ripper::RubyBuilder.new(src).parse
    @args = @code.select(Ruby::ArgsList).first.to_translate_args_list
  end

  # test type variations

  define_method "test: replace a simple symbol at position 1 with a simple symbol" do
    init("t(:bar)")
  
    @args.replace_key(:bar, :oooooooo)
      
    assert_equal [0, 1], @args.position.to_a
    assert_equal 11, @args.length
      
    assert_equal '(:oooooooo)', @args.to_ruby
    assert_equal '(:oooooooo)', @args.src
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a simple symbol at position 2 with a simple symbol" do
    init("t(:'foo.bar')")
    @args.replace_key(:bar, :oooooooo)
    assert_equal '(:"foo.oooooooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a simple symbol at position 1 with a quoted symbol" do
    init("t(:bar)")
    @args.replace_key(:bar, :'oooo.oooo')
    assert_equal '(:"oooo.oooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a simple symbol at position 2 with a quoted symbol" do
    init("t(:'foo.bar')")
    @args.replace_key(:bar, :'oooo.oooo')
    assert_equal '(:"foo.oooo.oooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a simple symbol at position 1 with a string (results in a symbol)" do
    init("t(:bar)")
    @args.replace_key(:bar, 'oooooooo')
    assert_equal '(:oooooooo)', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a simple symbol at position 2 with a string (results in a symbol)" do
    init("t(:'foo.bar')")
    @args.replace_key(:bar, 'oooooooo')
    assert_equal '(:"foo.oooooooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 1 with a simple symbol" do
    init("t(:'foo.bar')")
    @args.replace_key(:'foo.bar', :oooooooo)
    assert_equal '(:oooooooo)', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 2 with a simple symbol" do
    init("t(:'bar.baz', :scope => :foo)")
    @args.replace_key(:'bar.baz', :oooooooo)
    assert_equal '(:"foo.oooooooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 1 with a quoted symbol" do
    init("t(:'foo.bar')")
    @args.replace_key(:'foo.bar', :'oooo.oooo')
    assert_equal "(:\"oooo.oooo\")", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 2 with a quoted symbol" do
    init("t(:'bar.baz', :scope => :foo)")
    @args.replace_key(:'bar.baz', :'oooo.oooo')
    assert_equal "(:\"oooo.oooo\", :scope => :foo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 1 with a string (results in a symbol)" do
    init("t(:'foo.bar')")
    @args.replace_key(:'foo.bar', 'oooooooo')
    assert_equal "(:oooooooo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a quoted symbol at position 2 with a string (results in a symbol)" do
    init("t(:'bar.baz', :scope => :foo)")
    @args.replace_key(:'bar.baz', 'oooooooo')
    assert_equal '(:"foo.oooooooo")', @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a string at position 1 with a simple symbol" do
    init("t('bar_1')")
    @args.replace_key('bar_1', :oooooooo)
    assert_equal "(:oooooooo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a string at position 1 with a quoted symbol" do
    init("t('bar_1')")
    @args.replace_key('bar_1', :'oooo.oooo')
    assert_equal "(:\"oooo.oooo\")", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method "test: replace a string at position 1 with a string (results in a symbol)" do
    init("t('bar_1')")
    @args.replace_key('bar_1', 'oooooooo')
    assert_equal "(:oooooooo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  
  # test count variations
  
  define_method :"test: replace_key :foo with :fuh in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo], [:fuh])
    assert_equal "(:baz, :scope => [:fuh, :bar])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar] with [:fuh, :bah] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar], [:fuh, :bah])
    assert_equal "(:baz, :scope => [:fuh, :bah])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar] with [:fuh] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar], [:fuh])
    assert_equal "(:baz, :scope => :fuh)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo] with [:foo, :fuh] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo], [:foo, :fuh])
    assert_equal "(:baz, :scope => [:foo, :fuh, :bar])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar, :baz] with [:foo] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar, :baz], [:foo])
    assert_equal "(:foo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar, :baz] with [:foo, :bar] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar, :baz], [:foo, :bar])
    assert_equal "(:bar, :scope => :foo)", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar, :baz] with [:foo, :bar, :buz] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar, :baz], [:foo, :bar, :buz])
    assert_equal "(:buz, :scope => [:foo, :bar])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar, :baz] with [:foo, :bar, :baz, :buz] in (:baz, :scope => [:foo, :bar])" do
    init("t(:baz, :scope => [:'foo', :bar])")
  
    @args.replace_key([:foo, :bar, :baz], [:foo, :bar, :baz, :buz])
    assert_equal "(:buz, :scope => [:foo, :bar, :baz])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace_key [:foo, :bar] with [:foo, :bar, :baz] in (:bar, :scope => [:foo])" do
    init("t(:bar, :scope => [:foo])")
  
    @args.replace_key([:foo, :bar], [:foo, :bar, :baz])
    assert_equal "(:baz, :scope => [:foo, :bar])", @args.to_ruby
    assert_equal @args.parent.to_ruby, @args.root.src
  end
  
  define_method :"test: replace a few keys on the same line and next line" do
    src = "t(:a, :scope => [:a]); t(:b, :scope => [:b]);\n t(:c, :scope => [:ccc])\nt(:d, :scope => :d)\ne(:e)"
    calls = Ripper::RubyBuilder.new(src).parse.statements
  
    tokens = %w(a b c d e)
    calls = ::Hash[*tokens.zip(calls).flatten]
    src   = ::Hash[*tokens.zip(calls.values.map { |c| c.src }).flatten]
  
    calls['a'].to_translate_call.arguments.replace_key([:a], [:aaa])
    calls['b'].to_translate_call.arguments.replace_key([:b], [:bbb])
    calls['c'].to_translate_call.arguments.replace_key([:ccc], [:cc])
  
    assert_equal 't(:a, :scope => :aaa)', calls['a'].src
    assert_equal 't(:b, :scope => :bbb)', calls['b'].src
    assert_equal 't(:c, :scope => :cc)',  calls['c'].src
    assert_equal 't(:d, :scope => :d)',   calls['d'].src
    assert_equal 'e(:e)',                 calls['e'].src
  end
end

