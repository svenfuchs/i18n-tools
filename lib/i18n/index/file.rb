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
  	  attr_accessor :filename

  	  def initialize(filename)
  	    self.filename = filename
	    end

	    def source
	      @source ||= begin
	        source = ::File.read(filename) # TODO srsly ... how am i supposed to open a file in ruby 1.9?
	        source = ::File.open(filename, 'r:iso-8859-1:utf-8') { |f| f.read } unless source.valid_encoding?
	        source
        end
      end
	    
	    def ruby
	      @ruby ||= begin
	        parser.parse
	      rescue Ripper::RubyBuilder::ParseError => e
	        puts "\nWARNING Ruby 1.9 incompatible syntax in: " + e.message.gsub(Dir.pwd, '') + ". Can not index file."
	        Ruby::Program.new(source, filename)
        end
      end
      
      def calls
        @calls ||= ruby.select_translate_calls
      end
      
      def update(source)
        @source = source
        save
      end

	    def save
        ::File.open(filename, 'w+') { |f| f.write(source) } # TODO need to modify/write unfiltered source for ERB
      end
      
      protected

        def parser
          @parser ||= Index.parser.new(source, filename)
        end
	  end
  end
end