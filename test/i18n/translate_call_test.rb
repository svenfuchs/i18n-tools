require File.dirname(__FILE__) + '/../test_helper'
require 'i18n/project'

class I18nTranslateCallTest < Test::Unit::TestCase
  include TestRubyBuilderHelper

  def translate_call(src)
    Ripper::RubyBuilder.new(src).parse.statements.first.to_translate_call
  end

  def translate_args(src)
    translate_call(src).arguments.tap { |args| class << args; public :key_index; end }
  end

  define_method :"test: to_translate_call includes TranslateCall to the meta class" do
    call = call('t(:foo)')
    assert !call.respond_to?(:key)
  
    call = call.to_translate_call
    assert call.respond_to?(:key)
  end
  
  define_method :"test: to_translate_call includes TranslateArgsList to the arguments' meta class" do
    call = call('t(:foo)')
    assert !call.arguments.respond_to?(:key)
  
    call = call.to_translate_call
    assert call.arguments.respond_to?(:key)
  end
  
  def test_collects_all_three_kinds_of_translate_calls
    src = "I18n.t(:foo); t('bar.baz', :scope => [:buz]); t :foo"
    builder = I18n::Ripper::RubyBuilder.new(src)
    builder.parse
    assert_equal 3, builder.translate_calls.size
  end
  
  def test_call_to_translate_call
    src = "t(:'bar.baz', :scope => [:foo])"
    call = Ripper::RubyBuilder.new(src).parse.statements.first
    translate_call = call.to_translate_call
  
    assert_equal call.target, translate_call.target
    assert_equal call.identifier.token, translate_call.identifier.token
    assert_equal call.to_ruby, translate_call.to_ruby
    assert_equal translate_call, translate_call.arguments.parent
  end
  
  def test_translate_call_key
    assert_equal 'bar.baz', translate_call("t('bar.baz', :scope => [:foo])").key
    assert_equal :'bar.baz', translate_call("t(:'bar.baz', :scope => [:foo])").key
    assert_equal [:bar, :baz], translate_call("t([:bar, :baz], :scope => [:foo])").key
  end
  
  def test_translate_call_scope
    assert_equal nil, translate_call("t(:bar)").scope
    assert_equal :foo, translate_call("t(:bar, :scope => :foo)").scope
    assert_equal :'foo.bar', translate_call("t(:bar, :scope => :'foo.bar')").scope
    assert_equal [:foo], translate_call("t(:bar, :scope => [:foo])").scope
  end
  
  def test_translate_call_full_key
    assert_equal [:bar], translate_call("t(:bar)").full_key
    assert_equal [:foo, :bar], translate_call("t(:bar, :scope => :foo)").full_key
    assert_equal [:foo, :bar, :baz], translate_call("t(:baz, :scope => :'foo.bar')").full_key
    assert_equal [:foo, :bar, :baz], translate_call("t(:baz, :scope => [:foo, :bar])").full_key
  end
  
  def test_translate_call_key_matches?
    assert translate_call("t(:foo)").key_matches?(:foo)
  
    assert translate_call("t(:'foo.bar')").key_matches?(:foo)
    assert translate_call("t(:'foo.bar')").key_matches?(:'foo.bar')
  
    assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:foo)
    assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'foo.bar')
    assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'foo.bar.baz')
  
    assert !translate_call("t(:foo)").key_matches?(:'bar')
    assert !translate_call("t(:foo)").key_matches?(:'foo.bar')
  
    assert !translate_call("t(:'foo.bar')").key_matches?(:'bar.baz')
    assert !translate_call("t(:'foo.bar')").key_matches?(:'foo.bar.baz')
  
    assert !translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'bar.baz')
  end

  def test_translate_call_key_index
    assert_equal 0, translate_args("t(:foo)").key_index([:foo])
    assert_equal 0, translate_args("t(:'foo.bar.baz')").key_index([:foo, :bar, :baz])
    assert_equal 0, translate_args("t(:'baz.buz', :scope => [:foo, :bar])").key_index([:foo])
    assert_equal 0, translate_args("t(:'baz.buz', :scope => [:foo, :bar])").key_index([:foo, :bar, :baz, :buz])

    assert_equal 1, translate_args("t(:'foo.bar.baz')").key_index([:bar, :baz])
    assert_equal 1, translate_args("t(:'baz.buz', :scope => [:foo, :bar])").key_index([:bar])
    assert_equal 1, translate_args("t(:'baz.buz', :scope => [:foo, :bar])").key_index([:bar, :baz, :buz])

    assert_equal nil, translate_args("t(:'foo.bar.baz')").key_index([:baz, :buz])
    assert_equal nil, translate_args("t(:'baz.buz', :scope => [:foo, :bar])").key_index([:buz, :bar])
  end
end