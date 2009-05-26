module I18n
  module Keys
    class Index
      module Formatter
        module Setup
          def setup(target)
            (class << target; self; end).send(:include, self)
          end
        end

        module Stdin
          extend Setup

          def build(*args)
            puts "building index \"#{name}\"" if I18n::Keys.verbose?
            super
            puts "\nfound #{occurences.size} occurences of #{keys.size} keys in #{files.size} files" if I18n::Keys.verbose?
          end

          def save
            puts "saving index \"#{name}\"" if I18n::Keys.verbose?
            super
          end

          def parse(file)
            # puts "  parsing #{file}" if I18n::Keys.verbose?
            putc '.' if I18n::Keys.verbose?
            super
          end

          # def each(*keys)
          #   puts "iterating occurences of: #{keys.map { |key| key.to_sym.inspect }.join(', ')}" if I18n::Keys.verbose?
          #   super
          # end
        end
      end
    end
  end
end
