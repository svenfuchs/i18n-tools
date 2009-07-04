module I18n
  module Index
    class Simple < Base
      module Storage
        class << self
          def included(target)
            target.send(:extend, ClassMethods)
          end
        end
        
        module ClassMethods
          def load_or_create(options = {})
            exists?(options) ? load(options) : create(options)
          end

          protected

            def create(options = {})
              index = Simple.new(options)
              index.update
              index
            end

            def load(options)
              ::File.open(filename(options), 'r') { |f| ::Marshal.load(f) }
            end

            def exists?(options)
              ::File.exists?(filename(options))
            end

            def filename(options)
              store_dir(options) + "/index.marshal"
            end

            def store_dir(options)
              root_dir = options[:root_dir] || Dir.pwd
              ::File.expand_path(root_dir + '/.i18n')
            end
        end
      end

      def exists?
        ::File.exists?(filename)
      end

      def update
        reset!
        build
        save
      end

      def save
        mkdir
        ::File.open(filename, 'w+') { |f| ::Marshal.dump(self, f) }
      end

      def delete
        FileUtils.rm(filename) if exists? rescue Errno::ENOENT
      end

      def filename
        self.class.send(:filename, :root_dir => root_dir)
      end
      
      def store_dir
        self.class.send(:store_dir, :root_dir => root_dir)
      end
      
      def mkdir
        FileUtils.mkdir_p(store_dir) unless ::File.exists?(store_dir)
      end
      
      def marshalled_vars
        super + [:built, :data]
      end
    end
  end
end