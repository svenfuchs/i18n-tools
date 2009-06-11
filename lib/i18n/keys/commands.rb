program :version, I18n::Keys::VERSION
program :description, 'ruby i18n tools'
 
command :find do |c|
  c.syntax = 'i18n find [key] --index --verbose'
  c.summary = 'Find keys passed to I18n.t()'
  c.example 'i18n find', 'i18n find foo bar --index'
  c.option '--index', 'Use an index'
  c.option '--verbose', 'Output information about index build'
  c.when_called do |args, options|
    I18n::Keys.verbose = options.verbose
    index = I18n::Keys.index(:index => options.index)
    index.each(*args.map { |arg| arg.dup }) { |call| puts call.to_s }
  end
end

command :replace do |c|
  c.syntax = 'i18n replace [key] [replacement] --index --verbose'
  c.summary = 'Replace keys passed to I18n.t() by something else'
  c.example 'i18n replace', 'i18n replace foo bar --index'
  c.option '--index', 'Use an index'
  c.option '--verbose', 'Output information about index build'
  c.option '--non-interactive', 'Run command without asking for confirmation'
  c.when_called do |args, options|
    search, replacement = args.shift, args.shift
    raise Commander::Runner::InvalidCommandError.new('Wrong number of arguments') unless search && replacement
    
    I18n::Keys.verbose = options.verbose
    interactive = !options.delete(:'non-interactive')
    
    @found = false
    index = I18n::Keys.index(:index => options.index)
    index.each(search.dup, replacement.dup) do |call|
      if I18n::Commands.replace?(call, replacement, :interactive => interactive)
        @found = true
        index.replace_key!(call, search, replacement) 
      end
    end
    
    puts "No occurences were found for: #{search}." unless @found
  end
end

module I18n
  module Commands
    class << self
      def replace?(call, replacement, options = {:interactive => true})
        return true if @all
        return false if @cancelled
        case answer = I18n::Commands.confirm_replacement(call, replacement)[0, 1]
        when 'a'
          @all = true
        when 'c'
          @cancelled = true and false
        else
          answer == 'y'
        end
      end

      def confirm_replacement(call, replacement)
        puts call.to_s, call.context
        msg = "Replace this occurence of the key \"#{call.key}\" with \"#{replacement}\"? [Y]es [N]o [A]ll [C]ancel"
        answer = ask(msg, %w(y yes n no a all c cancel)) do |q|
          q.case = :downcase
          q.readline = true
        end
      end
    end
  end
end