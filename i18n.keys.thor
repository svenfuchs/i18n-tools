$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/vendor/ripper2ruby/lib')

require 'i18n/keys/commands'
require 'thor'

module I18n
  class Keys < Thor
    desc "find KEYS", "Find I18n keys in your source code"
    method_options :index => :optional,
                   :dir     => :optional,
                   :pattern => :optional,
                   :verbose => :boolean,
                   :context => :numeric

    def find(keys)
      ::I18n::Commands::Keys.new.find(keys, options.dup)
    end

    desc "replace SEARCH REPLACE", "Replace I18n keys in your source code and translation dictionaries"
    method_options :index => :optional,
                   :dir     => :optional,
                   :pattern => :optional,
                   :verbose => :boolean,
                   :context => :numeric

    def replace(search, replace)
      ::I18n::Commands::Keys.new.replace(search, replace, options.dup)
    end
  end
end