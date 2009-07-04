require 'core_ext/object/instance_variables'

module I18n
  module Index
    class Base
      attr_accessor :root_dir, :pattern

      def initialize(options = {})
        @root_dir = options[:root_dir] || Dir.pwd
        @pattern = options[:pattern] || Index.default_pattern
        options[:format].setup(self) if options[:format]
      end

      def filenames
        Dir[root_dir + '/' + pattern]
      end

      def files
        @files ||= Files.new
      end

      protected
      
        def marshalled_vars
          # TODO marshalling :files works but makes things much slower during tests - check this for real situations
          [:root_dir, :pattern] 
        end

        def marshal_dump
          instance_variables_get(*marshalled_vars)
        end

        def marshal_load(data)
          instance_variables_set(data.slice(*marshalled_vars))
        end
    end
  end
end