require File.dirname(__FILE__) + '/../../test_helper'

require 'i18n/index'
require 'yaml'

class I18nIndexSimpleTest < Test::Unit::TestCase
  def setup
    @root_dir = File.dirname(__FILE__) + '/../../fixtures'
    @filename = @root_dir + '/source_1.rb'
    @index = I18n::Index::Simple.new(:root_dir => @root_dir, :pattern => File.basename(@filename))
    FileUtils.cp(@filename, "#{@filename}.backup")
  end

  def teardown
    @index.delete
    FileUtils.mv("#{@filename}.backup", @filename)
  end


  def assert_valid_index(index)
    assert_equal 'source_1.rb', index.pattern
    assert_equal 'fixtures', File.basename(index.root_dir)

    keys = [:baaar, :bar, :bar_1, :"baz.fooo.baar", :"foo.bar"]
    assert_equal keys.sort, index.data.keys.map(&:key).sort
    assert_equal 2, index.data[:bar][:occurences].size

    occurence = index.send(:data)[:bar][:occurences].first
    assert_equal :bar, occurence.key.key # yuck
    assert_equal 'source_1.rb', File.basename(occurence.filename)
    assert_equal [2, 4], occurence.position.to_a
  end

  define_method :"test data is built lazily" do
    assert_valid_index(@index)
  end

  define_method :"test update builds and saves index" do
    @index.update
    index = I18n::Index::Simple.send(:load, :root_dir => @root_dir)
    assert_valid_index(index)
  end

  define_method :"test finds a call" do
    assert_equal 't(:bar)', @index.find_call(:bar).to_ruby
  end

  define_method :"test subsequently replaces keys" do
    @index.update # build and save

    call = @index.find_call(:bar)
    assert call

    @index.replace_key(call, :bar, :bazooh)
    assert File.read(@filename) =~ /:bazooh/

    index = I18n::Index::Simple.send(:load, :root_dir => @root_dir) # reload the index
    call = index.find_call(:bar)
    assert call

    index.replace_key(call, :bar, :bazuuh)
    assert File.read(@filename) =~ /:bazuuh/

    index = I18n::Index::Simple.send(:load, :root_dir => @root_dir) # reload the index
    assert_nil index.find_call(:bar)
  end
end