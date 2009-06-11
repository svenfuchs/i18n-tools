require File.dirname(__FILE__) + '/../test_helper'
require 'i18n/project'

class I18nKeyFullReplaceTest < Test::Unit::TestCase
  def setup
    I18n::Keys::Index::Formatter.verbose = false
    @project = I18n::Project.new(:root_dir => File.expand_path(File.dirname(__FILE__) + '/../fixtures'))
  end

  def teardown
    @index.files.each { |file| FileUtils.mv("#{file}.backup", file) } if @index
  end

  def index(file)
    @index ||= I18n::Keys::Index.new(@project, :pattern => '/translate/' + file).tap do |index|
      index.files.each { |file| FileUtils.cp(file, "#{file}.backup") }
    end
  end
  
  def assert_key_replacements(index, search, replace)
    # p index.by_key.keys
    root = index.by_key[search].first.root
    calls = index.by_key[search].dup
  
    calls.each { |c| index.replace_key!(c, search, replace) }

    src = root.src.split("\n").join("\n")
    # puts '----------------', src
    search.to_s.split('.').each { |key| assert src.scan(key.to_s).empty? }
    replace.to_s.split('.').each { |key| assert src.scan(key.to_s).size == calls.size }

    assert_equal src, calls.map { |c| c.to_ruby }.join("\n")
    assert_equal src, calls.map { |c| c.src }.join("\n")
  end

  define_method :"test calls: subsequently replace single key :foo" do
    index = index('single_key.rb')
    assert_key_replacements(index, :foo, :fuh)
    assert_key_replacements(index, :fuh, :'foo.bah')
    
    index = index('single_key.rb')
    assert_key_replacements(index, :'foo.bah', :'fuh.bar')
    assert_key_replacements(index, :'fuh.bar', :'bah')
  end
  
  define_method :"test calls: subsequently replace [:foo, :bar]" do
    index = index('single_scope.rb')
    assert_key_replacements(index, :'foo.bar', :'fuh.bah')
    assert_key_replacements(index, :'fuh.bah', :'foo.bar.baz')
  
    index = index('single_scope.rb')
    assert_key_replacements(index, :'foo.bar.baz', :'fuh.bah')
    assert_key_replacements(index, :'fuh.bah', :'foo')
  end
  
  define_method :"test calls: subsequently replace [:foo, :bar]" do
    index = index('double_key.rb')
    assert_key_replacements(index, :'foo.bar.baz', :'fuh')
    assert_key_replacements(index, :'fuh', :'foo.bar.baz')

    index = index('double_key.rb')
    assert_key_replacements(index, :'foo.bar.baz', :'fuh.bah.bas.bus')
    assert_key_replacements(index, :'fuh.bah.bas.bus', :'foo')
  end
  
  # TODO add more tests for partial key matches
end
