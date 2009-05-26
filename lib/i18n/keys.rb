require File.dirname(__FILE__) + '/parser/ruby_parser'
require File.dirname(__FILE__) + '/parser/erb_parser'
require File.dirname(__FILE__) + '/keys/index'

module I18n
  module Keys
    VERSION = '0.0.1'
    
    @@root = '.'
    @@verbose = true
    
    class << self
      def verbose?
        @@verbose
      end

      def verbose=(verbose)
        @@verbose = !!verbose
      end
      
      def root
        @@root
      end

      def root=(dir)
        @@root = dir
      end
      
      def meta_dir
        dir = root + '/.i18n'
        FileUtils.mkdir(dir) unless File.exists?(dir)
        dir
      end
    
      def config
        @config ||= YAML.load_file(meta_dir + '/config.yml') rescue { 'indices' => {} }
      end
      
      def config=(config)
        @config = config
      end
      
      def index(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        name = args.first || options.delete(:index)
        index = Index.load_or_create_or_init(name, options)
        index
      end
    end
  end
end