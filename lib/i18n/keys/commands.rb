require 'i18n/project'
require 'i18n/keys/index'
require 'highline/import'
require 'highlighters/ansi'

module I18n
  module Commands
    class Keys
      def initialize(highlighter = Highlighters::Ansi.new(:red, :bold))
        @highlighter = highlighter
      end
        
      def find(keys, options = {})
        index, pattern, dir, context, verbose = 
          options.values_at(:index, :pattern, :dir, :context, :verbose)
          
        I18n::Keys::Index::Formatter.verbose = verbose
        
        project = ::I18n::Project.new(:root_dir => dir)
        
        project.keys(index, :pattern => pattern).each(*keys) do |call|
           puts "\n" + call.to_s(:context => context, :highlight => @highlighter)
        end
      end

      def replace(search, replace, options)
        interactive = options.has_key?(:'interactive') ? options[:'interactive'] : true
        found = false

        index, pattern, dir, context, verbose = 
          options.values_at(:index, :pattern, :dir, :context, :verbose)

        I18n::Keys::Index::Formatter.verbose = verbose

        project = ::I18n::Project.new(:root_dir => dir)
        index = project.keys(index, :pattern => pattern)
        # $stdout.puts 'pre ---' + index.by_key.keys.inspect

        index.each(search) do |call|
          if replace?(call, replace, :interactive => interactive)
            project.replace_key(index, call, search, replace)
            found = true
          end
        end
        # $stdout.puts 'post ---' + index.by_key.keys.inspect

        puts "No occurences were found for: #{search}." unless found
      rescue I18n::KeyExists => e
        p e
      end

      protected

        def replace?(call, replace, options = { :interactive => true })
          return true if @all || !options[:interactive]
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
          puts call.context(:highlight => @highlighter)
          msg = "Replace this occurence of the key \"#{call.key}\" with \"#{replace}\"? [Y]es [N]o [A]ll [C]ancel"
          answer = ask(msg, %w(y yes n no a all c cancel)) do |q|
            q.case = :downcase
            q.readline = true
          end
        end
    end
  end
end