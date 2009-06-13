module I18n
  class Keys
    class Index
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
            puts "\nfound #{calls.size} occurences of #{keys.size} keys in #{files.size} files in total" if verbose?
          end

          def save
            puts "saving index \"#{name}\"" if verbose?
            super
          end

          def parse(file)
            # puts "  parsing #{file}" if verbose?
            putc '.' if verbose?
            super
          end

          # def each(*keys)
          #   puts "iterating occurences of: #{keys.map { |key| key.to_sym.inspect }.join(', ')}" if verbose?
          #   super
          # end
        end
      end
    end
  end
end
