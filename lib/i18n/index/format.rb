# wicked. but i can't see a better pattern right now. i want a module to include
# into the meta_class. and i don't want to set the io object globally (or on
# any class or module var) so i need to instantiate something, too.

module I18n
  module Index
    module Format
      class Base
        attr_accessor :io

        def initialize(io = nil)
          self.io = io || $stdout
        end
        
        def out(str)
          io.print(str)
        end

        def setup(target)
          $stdout.sync = true
          (class << target; self; end).send(:include, self.class::Hooks)
          target.format = self
        end
      end

      class Stdout < Base
        module Hooks
          attr_accessor :format
          
          def build(*args)
            format.out "indexing files ... "
            super
            format.out "found #{occurences.size} occurences of #{keys.size} keys in #{filenames.size} files in total\n"
          end

          def save
            format.out "saving index\n"
            super
          end

          def parse(file)
            # puts "  parsing #{::File.expand_path(file)}"
            format.out '.'
            super
          end
        end
      end
    end
  end
end
