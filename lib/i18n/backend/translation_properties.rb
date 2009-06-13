module I18n
  module Backend
    module TranslationProperties
      def property_names
        @property_names ||= []
      end
      
      def set_properties(properties)
        properties.each { |name, value| set_property(name, value) }
      end
      
      def set_property(name, value)
        add_property(name)
        send(:"#{name}=", value)
      end
      
      def add_property(name)
        unless respond_to?(name)
          TranslationProperties.send(:attr_accessor, name)
          property_names << name 
        end
      end
      
      def unset_properties
        property_names.each { |name| remove_instance_variable("@#{name}".to_sym) }
      end
    end
  end
end