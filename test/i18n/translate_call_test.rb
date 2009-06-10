require File.dirname(__FILE__) + '/../test_helper'

require 'i18n/project'
# require 'i18n/ripper/ruby_builder'
# require 'i18n/ruby/translate_call'

# class RipperToRubyTranslateCallTest < Test::Unit::TestCase
#   include TestRubyBuilderHelper
# 
#   define_method :"test: to_translate_call includes TranslateCall to the meta class" do
#     call = call('t(:foo)')
#     assert !call.respond_to?(:key)
# 
#     call = call.to_translate_call
#     assert call.respond_to?(:key)
#   end
# 
#   define_method :"test: to_translate_call includes TranslateArgsList to the arguments' meta class" do
#     call = call('t(:foo)')
#     assert !call.arguments.respond_to?(:key)
# 
#     call = call.to_translate_call
#     assert call.arguments.respond_to?(:key)
#   end
# 
#   def test_collect_translate_calls
#     src = "I18n.t(:foo); t('bar.baz', :scope => [:buz])"
#     builder = I18n::Ripper::RubyBuilder.new(src)
#     builder.parse
#     assert_equal 2, builder.translate_calls.size
#   end
# 
#   def test_call_to_translate_call
#     src = "t(:'bar.baz', :scope => [:foo])"
#     call = Ripper::RubyBuilder.new(src).parse.statements.first
#     translate_call = call.to_translate_call
# 
#     assert_equal call.target, translate_call.target
#     assert_equal call.identifier.token, translate_call.identifier.token
#     assert_equal call.to_ruby, translate_call.to_ruby
#     assert_equal translate_call, translate_call.arguments.parent
#   end
# 
#   def translate_call(src)
#     Ripper::RubyBuilder.new(src).parse.statements.first.to_translate_call
#   end
# 
#   def test_translate_call_key
#     assert_equal 'bar.baz', translate_call("t('bar.baz', :scope => [:foo])").key
#     assert_equal :'bar.baz', translate_call("t(:'bar.baz', :scope => [:foo])").key
#     assert_equal [:bar, :baz], translate_call("t([:bar, :baz], :scope => [:foo])").key
#   end
# 
#   def test_translate_call_scope
#     assert_equal nil, translate_call("t(:bar)").scope
#     assert_equal :foo, translate_call("t(:bar, :scope => :foo)").scope
#     assert_equal :'foo.bar', translate_call("t(:bar, :scope => :'foo.bar')").scope
#     assert_equal [:foo], translate_call("t(:bar, :scope => [:foo])").scope
#   end
# 
#   def test_translate_call_full_key
#     assert_equal [:bar], translate_call("t(:bar)").full_key
#     assert_equal [:foo, :bar], translate_call("t(:bar, :scope => :foo)").full_key
#     assert_equal [:foo, :bar, :baz], translate_call("t(:baz, :scope => :'foo.bar')").full_key
#     assert_equal [:foo, :bar, :baz], translate_call("t(:baz, :scope => [:foo, :bar])").full_key
#   end
# 
#   def test_translate_call_key_matches?
#     assert translate_call("t(:foo)").key_matches?(:foo)
# 
#     assert translate_call("t(:'foo.bar')").key_matches?(:foo)
#     assert translate_call("t(:'foo.bar')").key_matches?(:'foo.bar')
# 
#     assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:foo)
#     assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'foo.bar')
#     assert translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'foo.bar.baz')
# 
#     assert !translate_call("t(:foo)").key_matches?(:'bar')
#     assert !translate_call("t(:foo)").key_matches?(:'foo.bar')
# 
#     assert !translate_call("t(:'foo.bar')").key_matches?(:'bar.baz')
#     assert !translate_call("t(:'foo.bar')").key_matches?(:'foo.bar.baz')
# 
#     assert !translate_call("t(:baz, :scope => [:foo, :bar])").key_matches?(:'bar.baz')
#   end
# end

class RipperToRubyTranslateCallReplaceTest < Test::Unit::TestCase
  def setup
    I18n::Keys::Index::Formatter.verbose = false

    @filename = File.dirname(__FILE__) + "/../fixtures/source_1.rb"
    FileUtils.cp(@filename, "#{@filename}.backup")

    @project = I18n::Project.new(:root_dir => File.expand_path(File.dirname(__FILE__) + '/../fixtures'))
  end

  def teardown
    FileUtils.mv("#{@filename}.backup", @filename)
  end

  def call(key = :bar)
    index = I18n::Keys::Index.new(@project, :pattern => '/source_*.{rb}')
    index.update
    index.by_key[key].first
  end

  def test_replace_simple_symbol_with_simple_symbol
    bar = call(:bar)
    bar.replace_key!(:bar, :oooooooo)
    assert_equal "    t(:oooooooo)", bar.line
  end

  def test_replace_simple_symbol_with_quoted_symbol
    bar = call(:bar)
    bar.replace_key!(:bar, :'oooo.oooo')
    assert_equal "    t(:\"oooo.oooo\")", bar.line
  end
  
  # def test_replace_simple_symbol_with_string
  #   bar = call(:bar)
  #   bar.replace_key!(:bar, 'oooooooo')
  #   assert_equal "    t(\"oooooooo\")", bar.line
  # end
  # 
  # def test_replace_quoted_symbol_with_simple_symbol
  #   bar = call(:'foo.bar')
  #   bar.replace_key!(:bar, :oooooooo)
  #   assert_equal "    t(oooooooo)", bar.line
  # end
  # 
  # def test_replace_quoted_symbol_with_quoted_symbol
  #   bar = call(:'foo.bar')
  #   bar.replace_key!(:bar, :'oooo.oooo')
  #   assert_equal "    t(:\"oooo.oooo\")", bar.line
  # end
  # 
  # def test_replace_quoted_symbol_with_string
  #   bar = call(:'foo.bar')
  #   bar.replace_key!(:bar, 'oooooooo')
  #   assert_equal "    t(\"oooooooo\")", bar.line
  # end
  # 
  # def test_replace_string_with_simple_symbol
  #   bar = call('bar_1')
  #   bar.replace_key!(:bar, :oooooooo)
  #   assert_equal "    t(:oooooooo)", bar.line
  # end
  # 
  # def test_replace_string_with_quoted_symbol
  #   bar = call('bar_1')
  #   bar.replace_key!(:bar, :'oooo.oooo')
  #   assert_equal "    t(:\"oooo.oooo\")", bar.line
  # end
  # 
  # def test_replace_string_with_string
  #   bar = call('bar_1')
  #   bar.replace_key!(:bar, 'oooooooo')
  #   assert_equal "    t(\"oooooooo\")", bar.line
  # end
end
