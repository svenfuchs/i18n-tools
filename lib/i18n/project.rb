require 'fileutils'
require 'yaml'
require 'i18n/keys/index/store'

module I18n
  class Project
    VERSION = '0.0.1'
    
    attr_accessor :root_dir, :store_dir
    
    def initialize(options = {})
      @root_dir  = options[:root_dir] || '.'
      @store_dir = options[:store_dir] || root_dir + '/.i18n'
    end
    
    def store_dir
      FileUtils.mkdir(@store_dir) unless File.exists?(@store_dir)
      @store_dir
    end
    
    def config
      @config ||= YAML.load_file(store_dir + '/config.yml') rescue { 'indices' => {} }
    end
    
    def config=(config)
      @config = config
    end

    def delete
      FileUtils.rm_r(store_dir) if exists? rescue Errno::ENOENT
    end

    def exists?(name = nil)
      File.exists?(store_dir)
    end
    
    def indices
      @indices ||= Keys::Index::Store.new(self)
    end
    
    def keys(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      name = options.delete(:index) # args.first || 
      indices.load_or_create_or_init(name, options) #.find(*args)
    end
  end
end