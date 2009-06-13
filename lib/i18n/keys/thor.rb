require 'thor'
module I18n; class Keys < Thor; end; end # make sure I18n::Keys inherits from Thor
require 'i18n/project'

module I18n
  class Keys < Thor
    desc "find KEYS", "Find keys passed to I18n.t() in your source code"
    method_options :index => :optional,
                   :verbose => :boolean,
                   :context => :numeric

    def find(*args)
      keys = args.reject { |arg| arg[0] == '-' }
      project = Project.new(:root_dir => File.expand_path('.'))
      project.keys(:pattern => '/**/*.rb').each(*keys) do |call|
         puts "\n" + call.to_s(:context => 1, :highlight => true)
      end
    end
    
    attr_writer :out
    
    def out
      @out || STDOUT
    end
    
    def puts(str)
      out.puts(str)
    end
  end
end