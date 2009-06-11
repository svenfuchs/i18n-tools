require File.dirname(__FILE__) + '/../test_helper'
require 'i18n/project'

class I18nKeyFullReplaceTest < Test::Unit::TestCase
  def setup
    I18n::Keys::Index::Formatter.verbose = false
    @project = I18n::Project.new(:root_dir => File.expand_path(File.dirname(__FILE__) + '/../fixtures'))
  end

  def teardown
    @index.files.each { |file| FileUtils.mv("#{file}.backup", file) } if @index
    @project.delete
  end

  def index(file)
    @index ||= @project.indices.load_or_create(:pattern => '/translate/' + file).tap do |index|
      index.files.each { |file| FileUtils.cp(file, "#{file}.backup") }
    end
  end
  
  def assert_key_replacements(index, search, replace)
    root = index.by_key.first[1].first.root

    calls = []
    index.each(search) do |call|
      calls << call
      index.replace_key!(call, search, replace)
    end

    src = root.src.split("\n").join("\n")
    # puts '----------------', src
    search.to_s.gsub(/[^\w\.]/, '').split('.').each { |key| assert src.scan(key.to_s).empty? unless key.empty? }
    replace.to_s.gsub(/[^\w\.]/, '').split('.').each { |key| assert src.scan(key.to_s).size == calls.size }

    assert_equal src, calls.map { |c| c.to_ruby }.join("\n")
    assert_equal src, calls.map { |c| c.src }.join("\n")
  end

  define_method :"test subsequent key replacements in: t(:foo)" do
    2.times do
      index = index('single_key.rb')
      assert_key_replacements(index, :foo, :'fuh.bah')
      assert_key_replacements(index, '*.bah', :foo)
      assert_key_replacements(index, 'fuh.*', '')
    end
  end

  define_method :"test subsequent key replacements in: t(:bar, :scope => :foo)" do
    2.times do
      index = index('single_scope.rb')
      assert_key_replacements(index, :'*.bar', :'bah.bas')
      assert_key_replacements(index, :'*.bah.bas', :'bar')
    end
  end
  
  define_method :"test subsequent key replacements in: t(:'bar.baz', :scope => :foo)" do
    2.times do
      index = index('double_key.rb')
      assert_key_replacements(index, :'foo.bar.baz', :'fuh.bah.bas.bus')
      assert_key_replacements(index, :'fuh.bah.bas.bus', :'foo.bar.baz')
    end
  end
  
  # TODO add more tests for partial key matches
end
