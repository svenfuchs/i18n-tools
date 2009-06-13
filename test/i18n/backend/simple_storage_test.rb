require File.dirname(__FILE__) + '/../../test_helper'
require 'i18n'
require 'i18n/backend/simple_storage'

class I18nSimpleStorageTest < Test::Unit::TestCase
  def setup
    @filenames = {
      :de => File.dirname(__FILE__) + '/../../fixtures/locale/de.yml',
      :en => File.dirname(__FILE__) + '/../../fixtures/locale/en.yml',
      :pr => File.dirname(__FILE__) + '/../../fixtures/locale/pr.yml'
    }
    I18n.load_path += @filenames.values_at(:de, :en)
    @backend = I18n.backend = I18n::Backend::SimpleStorage.new
  end

  def teardown
    File.delete(@filenames[:pr]) rescue nil
  end

  define_method :"test: sets filename property on translations" do
    assert_equal @filenames[:de], I18n.t(:'foo.bar', :locale => :de).filename
    assert_equal @filenames[:de], I18n.t(:'foo.baz', :locale => :de).filename
    assert_equal @filenames[:en], I18n.t(:'foo.bar', :locale => :en).filename
    assert_equal @filenames[:en], I18n.t(:'foo.baz', :locale => :en).filename
  end

  define_method :"test each_translation" do
    locales, keys, values = [], [], []
    I18n.backend.send(:each_translation) do |locale, key, value|
      locales << locale
      keys << key
      values << value
    end
    assert_equal [:de, :en], locales.uniq
    assert_equal [[:foo, :bar], [:foo, :baz]], keys.uniq.sort
    assert_equal %w(Bah Bar Bas Baz), values.sort
  end

  define_method :"test select_translations" do
    translations = @backend.send(:select_translations) { |keys, translation| translation.filename =~ /de.yml/ }
    expected = { :de => { :foo => { :bar => "Bah", :baz => "Bas" } } }
    assert_equal expected, translations
  end

  define_method :"test by_filename" do
    translations = @backend.send(:by_filename, @filenames[:de])
    expected = { :de => { :foo => { :bar => "Bah", :baz => "Bas" } } }
    assert_equal expected, translations
  end

  define_method :"test save_translations" do
    filename = @filenames[:pr]
    data = @backend.send(:by_filename, @filenames[:de])[:de].deep_clone

    @backend.send(:set_translation_properties, data, :filename => filename)
    @backend.store_translations(:pr, data)
    @backend.save_translations(filename)

    expected = I18n.backend.send(:deep_stringify_keys, :pr => data)
    assert_equal(expected, YAML.load_file(filename))
    assert_equal(['bar', 'baz'], YAML.load_file(filename)['pr']['foo'].keys)
    assert_equal "--- \npr: \n  foo: \n    bar: Bah\n    baz: Bas\n", File.read(filename)
  end

  define_method :"test remove_translation" do
    assert_equal({ :bar => "Bar", :baz => "Baz" }, I18n.t(:foo))

    @backend.remove_translation([:foo, :bar])
    assert_equal({ :baz => "Baz" }, I18n.t(:foo))

    @backend.remove_translation([:foo])
    assert_equal "translation missing: en, foo", I18n.t(:foo)
    assert_equal "translation missing: de, foo", I18n.t(:foo, :locale => :de)
  end

  define_method :"test store_translation does not overwrite existing keys" do
    assert_equal({ :bar => "Bar", :baz => "Baz" }, I18n.t(:foo))
    assert_raises(I18n::KeyExists) { @backend.store_translations(:en, :foo => 'Foo') }
    assert_equal({ :bar => "Bar", :baz => "Baz" }, I18n.t(:foo))
  end
end