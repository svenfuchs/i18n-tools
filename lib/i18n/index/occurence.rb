module I18n
  module Index
  	class Occurence
  		attr_reader :key, :filename, :position
		
  		def initialize(key, filename, position)
  		  @key = key
  		  @filename = filename
  		  @position = position
  	  end
      
      def ==(other)
        key == other.key && filename == other.filename && position == other.position
      end
      alias eql? ==
  	end
	end
end