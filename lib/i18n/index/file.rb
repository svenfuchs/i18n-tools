module I18n
  module Index
    class Files < Hash
      def [](filename)
        fetch(filename) 
      rescue
        store(filename, File.new(filename))
      end
    end
    
  	class File
  	  attr_accessor :path, :source

  	  def initialize(path)
  	    self.path = path
	    end

	    def source
	      @source ||= Index.filter(::File.read(path), path)
      end
	    
	    def ruby
	      parser.ruby
      end
      
      def calls
        parser.translate_calls
      end
      
      def update(source)
        self.source = source
        save
      end

	    def save
        ::File.open(path, 'w+') { |f| f.write(source) }
      end
      
      protected

        def parser
          @parser ||= Index.parser.new(source, path).tap { |p| p.parse }
        end
	  end
  end
end