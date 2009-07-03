# TODO require gems instead
$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/vendor/ripper2ruby/lib')

require 'i18n/commands/keys'
require 'thor'

module I18n
  class Keys < Thor
    desc "find KEYS", "Find I18n keys in your source code"
    method_options :index   => :optional, # whether to use an index or not, if so: build or load 
                   :dir     => :optional, # root directory to search files in
                   :pattern => :optional, # pattern to use for searching files
                   :context => :numeric   # number of context lines to display

    def find(keys)
      options[:root_dir] = options.delete(:dir)
      ::I18n::Commands::Keys.new.find(keys, options.dup)
    end

    desc "replace SEARCH REPLACE", "Replace I18n keys in your source code and translation dictionaries"
    method_options :index   => :optional, # whether to use an index or not, if so: build or load 
                   :dir     => :optional, # root directory to search files in
                   :pattern => :optional, # pattern to use for searching files
                   :context => :numeric,  # number of context lines to display
                   :verbose => :boolean   # make any noise?

    def replace(search, replace)
      options[:root_dir] = options.delete(:dir)
      ::I18n::Commands::Keys.new.replace(search, replace, options.dup)
    end
  end
end