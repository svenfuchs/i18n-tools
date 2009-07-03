require File.dirname(__FILE__) + '/../../test_helper'
require 'fileutils'
require 'i18n/backend/simple_storage'

class I18nCommandsKeysTest < Test::Unit::TestCase
  @@fixtures_dir = File.expand_path(File.dirname(__FILE__) + '/../../fixtures/')
  @@backup_dir = File.expand_path(File.dirname(__FILE__) + '/../../tmp/')

  def setup
    I18n.backend = I18n::Backend::SimpleStorage.new
    @options = { :root_dir => @@fixtures_dir, :pattern => 'source_1.rb', :interactive => false }
    FileUtils.cp_r(@@fixtures_dir, @@backup_dir)
    @io = StringIO.new
    @commands = I18n::Commands::Keys.new(nil, @io)
  end

  def teardown
    FileUtils.rm_r(@@fixtures_dir)
    FileUtils.mv(@@backup_dir, @@fixtures_dir)
    I18n::Index.new.delete
  end
  
  def source(filename)
    File.read(@@fixtures_dir + "/#{filename}")
  end

  define_method :"test find command" do
    key = 'baaar'
    filename = 'source_1.rb'
    @commands.find(key, @options)

    assert_match @io.string, %r(indexing files)
    assert_match @io.string, %r(#{key}:.*#{filename})
  end

  define_method :"test replace command" do
    filename = 'source_1.rb'
    I18n.load_path += Dir[@@fixtures_dir + '/locale/*.yml']
    
    assert_not_nil I18n.t(:foo)
    assert_match %r(foo\.bar), source(filename)
    assert_equal [:bar, :baaar, :"baz.fooo.baar", :"foo.bar", :bar_1], indexed_keys
    
    @commands.replace('foo.*', 'baz', @options)
      
    assert_equal({ :bar => 'Bar', :baz => 'Baz' }, I18n.t(:baz))
    assert_raises(I18n::MissingTranslationData) { I18n.t(:foo, :raise => true) }
    assert_match %r(baz\.bar), source(filename)
    assert_no_match %r(foo\.bar), source(filename)
    assert_equal [:bar, :baaar, :"baz.fooo.baar", :bar_1, :"baz.bar"], indexed_keys
      
    @commands.replace('baz.bar', 'bazzz', @options)
      
    assert_equal 'Bar', I18n.t(:bazzz)
    assert_raises(I18n::MissingTranslationData) { I18n.t(:'baz.bar', :raise => true) }
    assert_match %r(bazzz), source(filename)
    assert_no_match %r(baz\.bar), source(filename)
    assert_equal [:bar, :baaar, :"baz.fooo.baar", :bar_1, :"bazzz"], indexed_keys
  end

  protected
  
    def indexed_keys
      I18n::Index.load_or_create(@options).keys.map(&:key)
    end

    def stub_output(target)
      (class << target; self; end).class_eval do
        attr_accessor :out
        define_method(:puts) { |str| out.puts(str) }
        define_method(:string) { out.string }
      end
      target.out = StringIO.new
      target
    end
end