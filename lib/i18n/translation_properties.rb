module I18n
  module TranslationProperties
    class << self
      def property_names
        @property_names ||= []
      end
      
      def define_property(name)
        unless respond_to?(name)
          attr_accessor(name) 
          property_names << name unless property_names.include?(name)
        end
      end
    end
    
    def set_properties(properties)
      properties.each { |name, value| set_property(name, value) }
    end
    
    def set_property(name, value)
      TranslationProperties.define_property(name)
      send(:"#{name}=", value)
    end
    
    def unset_properties
      TranslationProperties.property_names.each do |name| 
        remove_instance_variable("@#{name}") rescue NameError
      end
    end
  end
end