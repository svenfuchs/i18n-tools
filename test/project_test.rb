require File.dirname(__FILE__) + '/test_helper'

require 'i18n/project'
require 'yaml'

class ProjectTest < Test::Unit::TestCase
  include I18n

  def setup
    I18n::Keys::Index::Formatter.verbose = false
    @project = Project.new(:root_dir => File.dirname(__FILE__) + '/fixtures')
  end

  def teardown
    @project.delete
  end
  
  def write_config
    File.open(@project.store_dir + '/config.yml', 'w+') do |file|
      YAML.dump({ 'indices' => { 'default' => { 'pattern' => 'foo' } } }, file)
    end
  end
  
  def test_root_dir_defaults_to_current_work_dir
    assert_equal File.expand_path('.'), Project.new.root_dir
  end
  
  def test_can_set_root_dir
    assert_nothing_raised { @project.root_dir = 'path/to/root' }
    assert_equal 'path/to/root', @project.root_dir
  end
  
  def test_can_set_store_dir
    assert_nothing_raised { @project.store_dir = @project.root_dir + '/.i18n-2' }
    assert_equal @project.root_dir + '/.i18n-2', @project.store_dir
  end
  
  def test_creates_store_dir_on_access
    @project.store_dir = @project.root_dir + '/.i18n-2'
    assert File.exists?(@project.store_dir)
  end
  
  def test_defaults_config_to_hash_with_indices_set
    assert_equal({ 'indices' => {} }, @project.config)
  end
  
  def test_reads_config_from_store_config_yml_if_exists
    write_config
    assert_equal 'foo', @project.config['indices']['default']['pattern']
  end
  
  def test_keys_given_no_name_returns_an_unbuilt_and_unsaved_index
    index = @project.keys
    assert_equal Keys::Index, index.class
    assert !index.built?
    assert !index.exists?
  end
  
  def test_keys_given_true_as_a_name_returns_the_built_default_index
    index = @project.keys(:index => true)
    assert_equal Keys::Index, index.class
    assert_equal :default, index.name
    assert index.built?
    assert index.exists?
  end
  
  def test_keys_given_a_regular_name_returns_the_built_named_index
    index = @project.keys(:index => :foo)
    assert_equal Keys::Index, index.class
    assert_equal :foo, index.name
    assert index.built?
    assert index.exists?
  end
end