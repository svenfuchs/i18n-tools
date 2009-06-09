require File.dirname(__FILE__) + '/../test_helper'

require 'i18n/project'
require 'yaml'

class I18nIndexTest < Test::Unit::TestCase
  include I18n

  def setup
    I18n::Keys::Index::Formatter.verbose = false
    @filenames = %W( #{File.dirname(__FILE__)}/../fixtures/source_1.rb
                     #{File.dirname(__FILE__)}/../fixtures/source_2.rb )

    @project = Project.new(:root_dir => File.expand_path(File.dirname(__FILE__) + '/../fixtures'))
    FileUtils.cp(@filenames[0], "#{@filenames[0]}.backup")
  end
  
  def teardown
    @project.delete
    FileUtils.mv("#{@filenames[0]}.backup", @filenames[0])
  end

  def test_index_default_pattern
    assert_equal '/**/*.{rb,erb}', Keys::Index.new(@project).pattern
  end

  def test_index_finds_files
    expected = @filenames.map { |p| File.expand_path(p) }
    assert_equal expected, Keys::Index.new(@project).files & expected
  end
  
  def test_calls_built_lazily_on_a_fresh_index
    index = Keys::Index.new(@project, :default, :pattern => '/source_*.{rb}')
    expected = [:bar, :baaar, :baar, 'bar', 'bar_1', :bar_2]
    assert_equal expected, index.calls.select { |key| expected.include?(key.key) }.map { |c| c.key }
  end
  
  def test_calls_from_marshalled_index
    index = Keys::Index.new(@project, :marshalled, :pattern => '/source_*.{rb}')
    index.update
    index = @project.indices.load(:marshalled)
    expected = [:bar, :baaar, :baar, 'bar', 'bar_1', :bar_2]
    assert_equal expected, index.calls.select { |key| expected.include?(key.key) }.map { |c| c.key }
  end
  
  def test_index_create_builds_and_saves_the_index
    index = Keys::Index.new(@project, :create)
    assert !index.exists?
    index = @project.indices.create(:create, :pattern => '/**/*.{rb}')
    assert index.built?
    assert index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end
  
  def test_index_load_or_create_creates_an_index
    index = @project.indices.load_or_create(:load_or_create, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end
  
  def test_index_load_or_create_or_init_with_no_name_given_does_not_save_the_index
    index = @project.indices.load_or_create_or_init(:pattern => '/**/*.{rb}')
    assert !index.exists?
    assert_equal '/**/*.{rb}', index.pattern
  end
  
  def test_index_load_or_create_or_init_with_true_given_saves_the_default_index
    index = @project.indices.load_or_create_or_init(true, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal :default, index.name
    assert_equal '/**/*.{rb}', index.pattern
  end
  
  def test_index_load_or_create_or_init_with_name_given_saves_the_named_index
    index = @project.indices.load_or_create_or_init(:foo, :pattern => '/**/*.{rb}')
    assert index.exists?
    assert_equal :foo, index.name
    assert_equal '/**/*.{rb}', index.pattern
  end
  
  def test_index_exists_is_true_when_index_directory_exists
    index = @project.indices.create('foo')
    assert index.exists?
    FileUtils.rm_r(index.filename)
    assert !index.exists?
  end
  
  def test_index_inject_with_no_keys_given_iterates_over_all_calls
    index = Keys::Index.new(@project, :pattern => '/source_*.{rb}')
    expected = [:bar, :baaar, :baar, :'foo.bar', 'bar', 'bar_1', :bar_2]
    result = index.inject([]) { |result, call| result << call.key }
    assert_equal expected, result
  end
  
  def test_index_inject_with_keys_given_iterates_over_calls_of_given_keys
    index = Keys::Index.new(@project, :pattern => '/**/source_*.{rb}')
    expected = [:bar, :baaar, :baar, 'bar']
    result = index.inject([], :bar, :baaar, :baar) { |result, call| result << call.key }
    assert_equal expected, result
  end
  
  def test_key_included_with_no_keys_given_returns_true
    index = Keys::Index.new(@project)
    assert index.send(:key_matches?, :foo, [])
  end
  
  def test_key_included_with_the_key_included_returns_true
    index = Keys::Index.new(@project)
    assert index.send(:key_matches?, :foo, { :foo => /^foo$/, :bar => /^bar$/ })
  end
  
  def test_key_pattern_with_no_wild_cards_returns_a_pattern_matching_only_the_key
    assert_equal /^foo\.bar$/, Keys::Index.new(@project).send(:key_pattern, :'foo.bar')
  end
  
  def test_key_pattern_with_a_dot_separated_wildcard_at_the_beginning
    assert_equal /\.foo\.bar$/, Keys::Index.new(@project).send(:key_pattern, :'*.foo.bar')
  end
  
  def test_key_pattern_with_a_dot_separated_wildcard_at_the_end
    assert_equal /^foo\.bar\./, Keys::Index.new(@project).send(:key_pattern, :'foo.bar.*')
  end
  
  def test_key_pattern_with_a_dot_separated_wildcard_at_the_beginning_and_end
    assert_equal /\.foo\.bar\./, Keys::Index.new(@project).send(:key_pattern, :'*.foo.bar.*')
  end
  
  # def test_replace_replaces_key_without_wildcard_in_source_file
  #   index = @project.indices.create(:replace)
  #   bar = index.by_key[:bar].first
  # 
  #   index.replace!(bar, 'foo')
  #   assert_equal "    t(:foo)\n", bar.line
  # 
  #   index = @project.indices.load(:replace)
  #   foo = index.by_key[:foo].first
  #   assert foo == bar
  # end
  
  # TODO
  # - output feedback on replace when --verbose is on
  # - update the yaml/rb files
  
end