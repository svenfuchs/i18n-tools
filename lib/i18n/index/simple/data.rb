module I18n
  module Index
    class Simple < Base
      class Data < Hash
        def add(call)
    	    key = Key.new(call.full_key(true))
    	    occurences(key) << Occurence.new(key, call.filename, call.position)
  	    end
  	    
        def remove(call)
    	    key = Key.new(call.full_key(true))
    	    occurences = occurences(key)
    	    occurences.delete(Occurence.new(key, call.filename, call.position))
    	    self.delete(key) if occurences.empty?
  	    end
	    
  	    def occurences(key)
  	      self[key] ||= { :occurences => [] }
  	      self[key][:occurences]
        end
        
        def [](key)
          key = Key.new(key) unless key.is_a?(Key)
          super
        end

        def []=(key, value)
          key = Key.new(key) unless key.is_a?(Key)
          super
        end
      end
    end
  end
end