require 'i18n/index'
require 'i18n/exceptions/key_exists'
require 'core_ext/hash/slice'
require 'highline/import'
require 'highlighters/ansi'

module I18n
  module Commands
    class Keys
      def initialize(highlighter = Highlighters::Ansi.new(:bold), out = $stdout)
        @highlighter = highlighter
        @out = out
      end

      def find(keys, options = {})
        index = index(options)
        index.find_calls(*keys).each do |call|
          log "\n" + call.to_s(:context => options[:context], :highlight => @highlighter).gsub(Dir.pwd, '')
        end
      end

      def replace(search, replace, options)
        key = search.gsub(/^\*\.|\.\*$/, '')
        interactive = options.has_key?(:'interactive') ? options[:'interactive'] : true
        index = index(options)
        found = false
        
        index.find_calls(search).each do |call|
          if replace?(call, replace, :interactive => interactive)
            I18n.backend.copy_translations(key, replace)
            index.replace_key(call, search, replace)
            I18n.backend.remove_translation(key)
            found = true
          end
          break if cancelled?
        end
        
        log "No occurences were found or no replacements made for: #{search}." unless found
      rescue I18n::KeyExists => e
        log e.message
      end

      protected
      
        def log(str)
          @out.puts(str)
        end

        def index(options) # TODO use context + verbose options
          method = options.delete(:index) ? :load_or_create : :new
          options = options.slice(:root_dir, :pattern, :format, :context)
          options[:format] ||= I18n::Index::Format::Stdout.new(@out)
          I18n::Index.send(method, options)
        end
        
        def cancelled?
          @cancelled
        end

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
          log call.to_s
          log call.context(:highlight => @highlighter)
          msg = "Replace this occurence of the key \"#{call.key}\" with \"#{replace}\"? [Y]es [N]o [A]ll [C]ancel"
          answer = ask(msg, %w(y yes n no a all c cancel)) do |q|
            q.case = :downcase
            q.readline = true
          end
        end
    end
  end
end