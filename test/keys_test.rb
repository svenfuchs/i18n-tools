require File.dirname(__FILE__) + '/test_helper'

class KeysTest < Test::Unit::TestCase
  include I18n

  def setup
    @filenames = %W( #{File.dirname(__FILE__)}/fixtures/source_1.rb
                     #{File.dirname(__FILE__)}/fixtures/source_2.rb )
    @default_keys_root, Keys.root = Keys.root, File.expand_path(File.dirname(__FILE__))
  end

  def teardown
    Keys::Index.delete_all
    Keys.root = @default_keys_root
    Keys.config = nil
  end
  
  def test_root_defaults_to_dot
    assert_equal '.', @default_keys_root
  end
  
  def test_can_set_root
    old_root = I18n::Keys.root
    assert_nothing_raised { I18n::Keys.root = 'path/to/root' }
    assert_equal 'path/to/root', I18n::Keys.root
    I18n::Keys.root = old_root
  end
  
  def test_index_given_no_name_returns_an_unbuilt_and_unsaved_index
    index = Keys.index
    assert_equal Keys::Index, index.class
    assert !index.built?
    assert !index.exists?
  end
  
  def test_index_given_true_as_a_name_returns_the_built_default_index
    index = Keys.index(true)
    assert_equal Keys::Index, index.class
    assert_equal :default, index.name
    assert index.built?
    assert index.exists?
  end
  
  def test_index_given_a_regular_name_returns_the_built_named_index
    index = Keys.index(:foo)
    assert_equal Keys::Index, index.class
    assert_equal :foo, index.name
    assert index.built?
    assert index.exists?
  end

  # def test_find_all_in_file
  #   expected = [:bar, :baaar, :baar, "bar", "bar_1"]
  #   keys = I18n::Keys.find(:files => @filenames[0])
  #   assert_equal expected, keys.select { |key| expected.include?(key.key) }.map(&:key)
  # end
  # 
  # def test_find_all_in_files
  #   expected = ['bar_1', :bar_2]
  #   keys = I18n::Keys.find(:files => @filenames)
  #   assert_equal expected, keys.select { |key| expected.include?(key.key) }.map(&:key)
  # end
  # 
  # def test_find_key_in_file
  #   expected = [:bar]
  #   keys = I18n::Keys.find(:keys => :bar, :files => @filenames[0])
  #   assert_equal expected, keys.select { |key| expected.include?(key.key) }.map(&:key)
  # end
  # 
  # def test_find_key_in_files
  #   expected = [:bar]
  #   keys = I18n::Keys.find(:keys => :bar, :files => @filenames)
  #   assert_equal expected, keys.select { |key| expected.include?(key.key) }.map(&:key)
  # end
end