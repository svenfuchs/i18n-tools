require 'i18n/project'
require 'i18n/keys/index'
require 'highline/import'

module I18n
  module Commands
    class Keys
      def find(keys, options = {})
        index, pattern, dir, context, verbose = 
          options.values_at(:index, :pattern, :dir, :context, :verbose)
          
        I18n::Keys::Index::Formatter.verbose = verbose
        
        project = ::I18n::Project.new(:root_dir => dir)
        project.keys(index, :pattern => pattern).each(*keys) do |call|
           puts "\n" + call.to_s(:context => context, :highlight => true)
        end
      end

      def replace(search, replace, options)
        interactive = true # options.delete(:'interactive')
        found = false

        index, pattern, dir, context, verbose = 
          options.values_at(:index, :pattern, :dir, :context, :verbose)
          
        I18n::Keys::Index::Formatter.verbose = verbose
        
        project = ::I18n::Project.new(:root_dir => dir)
        project.keys(index, :pattern => pattern).each(search) do |call|
          if replace?(call, replace, :interactive => interactive)
            # index.replace_key(call, search, replace)
            # found = true
          end
        end

        puts "No occurences were found for: #{search}." unless found
      end

      protected

        def replace?(call, replace, options = {:interactive => true})
          return true if @all
          return false if @cancelled
          case answer = confirm_replace(call, replace)[0, 1]
          when 'a'
            @all = true
          when 'c'
            @cancelled = true and false
          else
            answer == 'y'
          end
        end

        def confirm_replace(call, replace)
          puts call.to_s
          puts call.context(:highlight => true)
          msg = "Replace this occurence of the key \"#{call.key}\" with \"#{replace}\"? [Y]es [N]o [A]ll [C]ancel"
          answer = ask(msg, %w(y yes n no a all c cancel)) do |q|
            q.case = :downcase
            q.readline = true
          end
        end
    end
  end
end