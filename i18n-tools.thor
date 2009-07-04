# TODO require gems instead
$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/vendor/ripper2ruby/lib')

require 'core_ext/hash/symbolize_keys'
require 'i18n/commands/keys'
require 'thor'

module I18n
  class Keys < Thor
    desc "find KEYS", "Find I18n keys in your source code"
    method_options :index   => :boolean,  # load saved index if exists, save the current index
                   :dir     => :optional, # root directory to search files in
                   :pattern => :optional, # pattern to use for searching files
                   :context => :numeric   # number of context lines to display

    def find(keys)
      ::I18n::Commands::Keys.new.find(keys, normalize(options))
    end

    desc "replace SEARCH REPLACE", "Replace I18n keys in your source code and translation dictionaries"
    method_options :index   => :boolean,  # load saved index if exists, save the current index
                   :dir     => :optional, # root directory to search files in
                   :pattern => :optional, # pattern to use for searching files
                   :context => :numeric,  # number of context lines to display
                   :verbose => :boolean   # make any noise?

    def replace(search, replace)
      ::I18n::Commands::Keys.new.replace(search, replace, normalize(options))
    end
    
    protected
    
      def normalize(options)
        options = Hash[options.to_a] # i can haz hash
        options[:root_dir] = options.delete(:dir)
        options.symbolize_keys
      end
  end
end