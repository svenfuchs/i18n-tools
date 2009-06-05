module I18n
  module Keys
    class Source
      attr_reader :file
      
      def initialize(file)
        @file = file
      end

      def content
        lines.join
      end

      def lines
        @lines ||= File.open(file, 'r') { |f| f.readlines }
      end
      
      def replace(content)
        File.open(file, 'w+') { |f| f.write(content) }
        @lines = nil
      end
    end
  end
end