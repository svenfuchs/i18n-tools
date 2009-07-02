module I18n
  module Index
    class Simple
      module Formatter
        @@verbose = true # remove this class var dependency
    
        class << self
          def verbose?
            @@verbose
          end

          def verbose=(verbose)
            @@verbose = !!verbose
          end
        end

        module Setup
          def setup(target)
            $stdout.sync = true
            (class << target; self; end).send(:include, self)
          end
        end

        module Stdin
          extend Setup
          
          def verbose?
            Formatter.verbose?
          end

          def build(*args)
            puts "indexing files" if verbose?
            super
            puts "\nfound #{occurences.size} occurences of #{keys.size} keys in #{files.size} files in total" if verbose?
          end

          def save
            puts "saving index" if verbose?
            super
          end
          
          def parse(file)
            # puts "  parsing #{File.expand_path(file)}" if verbose?
            putc '.' if verbose?
            super
          end
        end
      end
    end
  end
end
