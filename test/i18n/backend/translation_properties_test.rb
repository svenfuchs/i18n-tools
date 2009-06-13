require File.dirname(__FILE__) + '/../../test_helper'
require 'i18n'
require 'i18n/backend/simple_storage'

class I18nTranslationPropertiesTest < Test::Unit::TestCase
  def setup
    @backend = I18n.backend = I18n::Backend::SimpleStorage.new
    @data = { :foo => 'Foo', :bar => 'Bar' }
    @backend.send(:set_translation_properties, @data, :filename => 'path/to/file.yml')
  end

  define_method :"test: set_translation_properties includes TranslationProperties to the value's metaclass" do
    assert @data[:foo].meta_class.include?(I18n::TranslationProperties)
    assert @data[:bar].meta_class.include?(I18n::TranslationProperties)
  end

  define_method :"test: set_translation_properties defines the properties on TranslationProperties" do
    assert_equal [:filename], I18n::TranslationProperties.property_names
  end

  define_method :"test: set_translation_properties sets the property values on the objects" do
    assert_equal 'path/to/file.yml', @data[:foo].filename
    assert_equal 'path/to/file.yml', @data[:bar].filename
  end

  define_method :"test: unset_translation_properties unsets the property instance_variables on the objects" do
    @backend.send(:unset_translation_properties, @data)
    assert_equal nil, @data[:foo].filename
    assert_equal nil, @data[:bar].filename
    assert_equal nil, @data[:foo].instance_variable_get(:@filename)
    assert_equal nil, @data[:bar].instance_variable_get(:@filename)
  end
end