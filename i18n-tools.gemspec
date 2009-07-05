Gem::Specification.new do |s|
  s.name = "i18n-tools"
  s.version = "0.0.6"
  s.date = "2009-05-26"
  s.summary = "Tools for Ruby/Rails I18n"
  s.email = "rails-i18n@googlegroups.com"
  s.homepage = "http://rails-i18n.org"
  s.description = "Tools for Ruby/Rails I18n"
  s.has_rdoc = false
  s.authors = ['Sven Fuchs']
  s.files = %w(
    lib/core_ext/hash/iterate_nested.rb
    lib/core_ext/hash/slice.rb
    lib/core_ext/hash/sorted_yaml_style.rb
    lib/core_ext/hash/symbolize_keys.rb
    lib/core_ext/module/attribute_accessors.rb
    lib/core_ext/object/deep_clone.rb
    lib/core_ext/object/instance_variables.rb
    lib/core_ext/object/meta_class.rb
    lib/core_ext/object/tap.rb
    lib/i18n/backend/simple_storage.rb
    lib/i18n/commands/keys.rb
    lib/i18n/exceptions/key_exists.rb
    lib/i18n/index/base.rb
    lib/i18n/index/file.rb
    lib/i18n/index/format.rb
    lib/i18n/index/key.rb
    lib/i18n/index/occurence.rb
    lib/i18n/index/simple/data.rb
    lib/i18n/index/simple/storage.rb
    lib/i18n/index/simple.rb
    lib/i18n/index.rb
    lib/i18n/ripper2ruby/translate_args_list.rb
    lib/i18n/ripper2ruby/translate_call.rb
    lib/i18n/ripper2ruby.rb
    lib/i18n/translation_properties.rb
  )
  s.test_files = %w(
    test/all.rb
    test/core_ext/hash_iterate_nested.rb
    test/fixtures/all.rb.src
    test/fixtures/config.yml
    test/fixtures/locale/de.yml
    test/fixtures/locale/en.yml
    test/fixtures/source_1.rb
    test/fixtures/source_2.rb
    test/fixtures/template.html.erb
    test/fixtures/translate/double_key.rb
    test/fixtures/translate/double_scope.rb
    test/fixtures/translate/single_key.rb
    test/fixtures/translate/single_scope.rb
    test/i18n/backend/simple_storage_test.rb
    test/i18n/backend/translation_properties_test.rb
    test/i18n/index/all.rb
    test/i18n/index/args_replace_test.rb
    test/i18n/index/calls_replace_test.rb
    test/i18n/index/commands_test.rb
    test/i18n/index/key_test.rb
    test/i18n/index/simple_test.rb
    test/i18n/ripper2ruby/translate_call_test.rb
    test/test_helper.rb 
  )
  # s.add_dependency('svenfuchs-ripper2ruby', ['>= 0.0.1'])
  # s.executables = ['i18n-keys']
  # s.default_executable = 'i18n-keys'
end
