require 'i18n/keys/index'

module I18n
  module Keys
    class Index
      class Store
        attr_reader :project
      
        def initialize(project)
          @project = project
        end
      
        def load_or_create_or_init(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          name = TrueClass === args.first ? :default : args.first
          index = name ? load_or_create(name, options) : Index.new(project, name, options)
          index
        end

        def load_or_create(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          name = args.first || :default
          exists?(name) ? load(name) : create(name, options)
        end

        def create(*args)
          index = Index.new(project, *args)
          index.update
          index
        end

        def load(name)
          File.open(filename(name), 'r') { |f| Marshal.load(f) } if exists?
        end

        def mk_dir
          FileUtils.mkdir_p(store_dir) unless exists?
        end

        def exists?(name = nil)
          name ? File.exists?(filename(name)) : File.exists?(store_dir)
        end

        def delete(name)
          new(name).delete
        end

        def delete_all
          FileUtils.rm_r(project.store_dir) if exists? rescue Errno::ENOENT
        end

        def filename(name)
          store_dir + "/#{name.to_s}.marshal"
        end

        def store_dir
          File.expand_path(project.store_dir + '/indizes')
        end
      end
    end
  end
end