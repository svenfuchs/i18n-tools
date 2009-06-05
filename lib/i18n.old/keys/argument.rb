module I18n
  module Keys
    class Argument < Range
      attr_reader :name, :value

      def initialize(name, value, source, start_pos, end_pos)
        @name = name
        @value = value
        super(source, start_pos, end_pos)
      end
      
      def replace(value)
        @value = value
        super
      end
    end
  end
end