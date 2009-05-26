require File.dirname(__FILE__) + '/test_helper'

class IndexTest < Test::Unit::TestCase
  include I18n

  def setup
    I18n::Keys.verbose = false
    @filenames = %W( #{File.dirname(__FILE__)}/fixtures/source_1.rb
                     #{File.dirname(__FILE__)}/fixtures/source_2.rb )
    @default_keys_root, Keys.root = Keys.root, File.expand_path(File.dirname(__FILE__)) + '/fixtures'
    FileUtils.cp(@filenames[0], "#{@filenames[0]}.backup")
  end

  def teardown
    Keys::Index.delete_all
    Keys.root = @default_keys_root
    FileUtils.mv("#{@filenames[0]}.backup", @filenames[0])
  end

  def test_index_default_pattern
    Keys.config = nil
    assert_equal '/**/*.{rb,erb}', Keys::Index.new.pattern
  end

  def test_index_finds_files
    expected = %w(test/fixtures/source_1.rb test/fixtures/source_2.rb).map { |p| File.expand_path(p) }
    assert_equal expected, Keys::Index.new.files & expected
  end

  def test_occurences_built_lazily_on_a_fresh_index
    index = Keys::Index.new(:default)
    expected = [:bar, :baaar, :baar, :bar, :bar_1, :bar_2]
    assert_equal expected, index.occurences.select { |key| expected.include?(key.key) }.map(&:key)
  end

  def test_occurences_from_marshalled_index
    index = Keys::Index.new(:marshalled)
    index.update
    index = Keys::Index.load(:marshalled)
    expected = [:bar, :baaar, :baar, :bar, :bar_1, :bar_2]
    assert_equal expected, index.occurences.select { |key| expected.include?(key.key) }.map(&:key)
  end

  def test_index_create_builds_and_saves_the_index
    index = Keys::Index.new(:create)
    assert !index.exists?
    index = Keys::Index.create(:create, :pattern => '/**/*.{rb}')
    assert index.built?
    assert index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end

  def test_index_load_or_create_creates_an_index
    index = Keys::Index.load_or_create(:load_or_create, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end

  def test_index_load_or_create_or_init_with_no_name_given_does_not_save_the_index
    index = Keys::Index.load_or_create_or_init(:pattern => '/**/*.{rb}')
    assert !index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end

  def test_index_load_or_create_or_init_with_true_given_saves_the_default_index
    index = Keys::Index.load_or_create_or_init(true, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal :default, index.name
    assert_equal '/**/*.{rb}', index.pattern
  end

  def test_index_load_or_create_or_init_with_name_given_saves_the_named_index
    index = Keys::Index.load_or_create_or_init(:foo, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal :foo, index.name
    assert_equal '/**/*.{rb}', index.pattern
  end

  def test_index_exists_is_true_when_index_directory_exists
    index = Keys::Index.create('foo')
    assert index.exists?
    FileUtils.rm_r(index.filename)
    assert !index.exists?
  end

  def test_index_inject_with_no_keys_given_iterates_over_all_occurences
    index = Keys::Index.new(:pattern => '/**/*.{rb}')
    expected = [:bar, :baaar, :baar, :'foo.bar', :bar, :bar_1, :bar_2]
    result = index.inject([]) { |result, occurence| result << occurence.key }
    assert_equal expected, result
  end

  def test_index_inject_with_keys_given_iterates_over_occurences_of_given_keys
    index = Keys::Index.new(:pattern => '/**/*.{rb}')
    expected = [:bar, :baaar, :baar, :bar]
    result = index.inject([], :bar, :baaar, :baar) { |result, occurence| result << occurence.key }
    assert_equal expected, result
  end

  def test_key_included_with_no_keys_given_returns_true
    index = Keys::Index.new
    assert index.send(:key_matches?, :foo, [])
  end

  def test_key_included_with_the_key_included_returns_true
    index = Keys::Index.new
    assert index.send(:key_matches?, :foo, { :foo => /^foo$/, :bar => /^bar$/ })
  end

  def test_key_pattern_with_no_wild_cards_returns_a_pattern_matching_only_the_key
    index = Keys::Index.new
    assert_equal /^foo\.bar$/, index.send(:key_pattern, :'foo.bar')
  end

  def test_key_pattern_with_a_dot_separated_wild_card_at_the_end_returns_a_pattern_matching_all_keys_starting_with_key
    index = Keys::Index.new
    assert_equal /^foo\.bar\./, index.send(:key_pattern, :'foo.bar.*')
  end
  
  def test_replace_replaces_key_without_wildcard_in_source_file
    index = Keys::Index.create(:replace)
    bar = index.by_key[:bar].first
    index.replace!(bar, 'foo')
    assert_equal "    t(:foo)\n", bar.line
    
    index = Keys::Index.load(:replace)
    foo = index.by_key[:bar].first
    assert foo == bar
  end
  
  # TODO
  # - after replace make sure the index is updated
  # - somehow also update the yaml/rb files
  
end