require 'fileutils'
require 'yaml'
require 'i18n/keys/index'

module I18n
  class Project
    VERSION = '0.0.1'
    
    attr_accessor :root_dir, :store_dir
    
    def initialize(options = {})
      @root_dir  = File.expand_path(options[:root_dir] || '.')
      @store_dir = File.expand_path(options[:store_dir] || root_dir + '/.i18n')
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
    
    def backend
      @backend ||= I18n.backend = I18n::Backend::SimpleStorage.new
    end
    
    def keys(*args)
      @index ||= begin
        options = args.last.is_a?(Hash) ? args.pop : {}
        name = options.delete(:index) 
        indices.load_or_create_or_init(name, options)
      end
    end
    
    def replace_key(index, call, search, replace)
      key = search.gsub(/^\*\.|\.\*$/, '')
      backend.copy_translations(key, replace)
      index.replace_key(call, search, replace)
      backend.remove_translation(key) # unless index.count(search) > 0
      backend.save_translations
    end
  end
end