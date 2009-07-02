require 'i18n/keys/index'

module I18n
  module Index
    class Simple
      @@marshalled = [:root_dir, :pattern, :built, :data]
      
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

          def delete_all(options)
            FileUtils.rm_r(store_dir(options)) rescue Errno::ENOENT
          end
          
          protected

            def create(options = {})
              index = Simple.new(options)
              index.update
              index
            end

            def load(options)
              File.open(filename(options), 'r') { |f| ::Marshal.load(f) }
            end

            def exists?(options)
              File.exists?(filename(options))
            end

            def filename(options)
              store_dir(options) + "/index.marshal"
            end

            def store_dir(options)
              File.expand_path(options[:root_dir] + '/.i18n')
            end
        end
      end

      def exists?
        File.exists?(filename)
      end

      def update
        reset!
        build
        save
      end

      def save
        mkdir
        File.open(filename, 'w+') { |f| ::Marshal.dump(self, f) }
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
        FileUtils.mkdir_p(store_dir) unless File.exists?(store_dir)
      end

      def marshal_dump
        @@marshalled.inject({}) { |result, key| result[key] = instance_variable_get(:"@#{key}"); result }
      end

      def marshal_load(data)
        @@marshalled.each { |key| instance_variable_set(:"@#{key}", data[key]) }
      end
    end
  end
end