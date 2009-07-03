module I18n
  module Index
    class Simple
      module Building
        def reset!
          @built = false
          @data = nil
        end
    
        def built?
          @built
        end

        def build
          reset!
          @built = true
          calls = files.inject([]) { |result, file| result += parse(file).translate_calls }
          calls.each { |call| data.add(call) }
        end

        def parse(file)
          source = File.read(file)
          source = Erb::Stripper.new.to_ruby(source) if File.extname(file) == '.erb'
          Index.parser.new(source, file).tap { |p| p.parse }
        end
      
        def files
          Dir[root_dir + '/' + pattern]
        end
      end
    end
  end
end