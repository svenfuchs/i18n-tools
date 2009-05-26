Gem::Specification.new do |s|
  s.name = "i18n-tools"
  s.version = "0.0.3"
  s.date = "2009-05-26"
  s.summary = "Tools for Ruby/Rails I18n"
  s.email = "rails-i18n@googlegroups.com"
  s.homepage = "http://rails-i18n.org"
  s.description = "Tools for Ruby/Rails I18n"
  s.has_rdoc = false
  s.authors = ['Sven Fuchs']
  s.files = [
    'bin/i18n-keys',
    'lib/ansi.rb',
    'lib/i18n/keys/commands.rb',
    'lib/i18n/keys/formatter.rb',
    'lib/i18n/keys/index.rb',
    'lib/i18n/keys/occurence.rb',
    'lib/i18n/keys.rb',
    'lib/i18n/parser/erb_parser.rb',
    'lib/i18n/parser/ruby_parser.rb',
    'MIT-LICENSE',
    'README.textile'
  ]
  s.test_files = [
    'test/all.rb',
    'test/commands_test.rb',
    'test/erb_parser_test.rb',
    'test/fixtures/source_1.rb',
    'test/fixtures/source_2.rb',
    'test/fixtures/template.html.erb',
    'test/index_test.rb',
    'test/keys_test.rb',
    'test/occurence_test.rb',
    'test/ruby_parser_test.rb',
    'test/test_helper.rb'
  ]
  s.add_dependency('visionmedia-commander', ['= 3.2.9'])
  s.executables = ['i18n-keys']
  s.default_executable = 'i18n-keys'
end
