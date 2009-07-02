module I18n
  module Index
  	class Occurence
  		attr_reader :key, :filename, :position
		
  		def initialize(key, filename, position)
  		  @key = key
  		  @filename = filename
  		  @position = position
  	  end

  		def code
  			Index.parser.build(nil, filename)
  		end
      
      def ==(other)
        key == other.key && filename == other.filename && position == other.position
      end
      alias eql? ==
		
  		def code
  			Index.parser.build(nil, filename)
  		end
  	end
	end
end