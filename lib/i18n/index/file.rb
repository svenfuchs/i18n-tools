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
  	  attr_accessor :path

  	  def initialize(path)
  	    self.path = path
	    end

	    def source
	      @source ||= Index.filter(::File.read(path), path)
      end
	    
	    def ruby
	      @ruby ||= parser.parse
      end
      
      def calls
        @calls ||= ruby.select_translate_calls
      end
      
      def update(source)
        @source = source
        save
      end

	    def save
        ::File.open(path, 'w+') { |f| f.write(source) } # TODO need to modify/write unfiltered source for ERB
      end
      
      protected

        def parser
          @parser ||= Index.parser.new(source, path)
        end
	  end
  end
end