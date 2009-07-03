require File.dirname(__FILE__) + '/../../test_helper'
require 'i18n/index'

class I18nCallReplaceTest < Test::Unit::TestCase
  def setup
    @root_dir = File.expand_path(File.dirname(__FILE__) + '/../../fixtures')
  end

  def teardown
    @index.send(:files).each { |file| FileUtils.mv("#{file}.backup", file) } if @index
    @index.delete
  end

  def index(file)
    @index ||= I18n::Index.load_or_create(:root_dir => @root_dir, :pattern => '/translate/' + file).tap do |index|
      index.files.each { |file| FileUtils.cp(file, "#{file}.backup") }
    end
  end

  def root(index)
    I18n::Index.ruby(index.occurences.first.filename).root
  end

  def assert_key_replacements(index, search, replace)
    calls = []

    while call = index.find_call(search)
      calls << call
      index.replace_key(call, search, replace)
      putc '.'
    end
    src = root(index).src

    search.to_s.gsub(/[^\w\.]/, '').split('.').each { |key| assert src.scan(key.to_s).empty? unless key.empty? }
    replace.to_s.gsub(/[^\w\.]/, '').split('.').each { |key| assert src.scan(key.to_s).size == calls.size }

    assert_equal src, calls.map { |c| c.to_ruby }.join("\n")
    assert_equal src, calls.map { |c| c.src }.join("\n")
  end

  define_method :"test subsequent key replacements in: t(:foo)" do
    2.times do
      index = index('single_key.rb')
      assert_key_replacements(index, :foo, :'fuh.bah') and putc '.'
      assert_key_replacements(index, '*.bah', :foo)    and putc '.'
      assert_key_replacements(index, 'fuh.*', '')      and putc '.'
    end
  end

  define_method :"test subsequent key replacements in: t(:bar, :scope => :foo)" do
    2.times do
      index = index('single_scope.rb')
      assert_key_replacements(index, :'*.bar', :'bah.bas') and putc '.'
      assert_key_replacements(index, :'*.bah.bas', :'bar') and putc '.'
    end
  end

  define_method :"test subsequent key replacements in: t(:'bar.baz', :scope => :foo)" do
    2.times do
      index = index('double_key.rb')
      assert_key_replacements(index, :'foo.bar.baz', :'fuh.bah.bas.bus') and putc '.'
      assert_key_replacements(index, :'fuh.bah.bas.bus', :'foo.bar.baz') and putc '.'
    end
  end

  # TODO add more tests for partial key matches
end
