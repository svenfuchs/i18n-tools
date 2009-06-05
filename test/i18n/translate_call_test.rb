require File.dirname(__FILE__) + '/../test_helper'

require 'i18n/ripper/ruby_builder'
require 'i18n/ruby/translate_call'

class RipperToRubyTranslateCallTest < Test::Unit::TestCase
  def test_collect_translate_calls
    src = "I18n.t(:foo); t('bar.baz', :scope => [:buz])"
    builder = I18n::Ripper::RubyBuilder.new(src)
    builder.parse
    assert_equal 2, builder.translate_calls.size
  end
  
  def test_call_to_translate_call
    src = "t(:'bar.baz', :scope => [:foo])"
    call = Ripper::RubyBuilder.new(src).parse.statements.first
    translate_call = call.to_translate_call
    
    assert_equal call.target, translate_call.target
    assert_equal call.identifier, translate_call.identifier
    assert_equal call.to_ruby, translate_call.to_ruby
    assert_equal translate_call, translate_call.arguments.parent
  end
  
  def translate_call(src)
    Ripper::RubyBuilder.new(src).parse.statements.first.to_translate_call
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
end
