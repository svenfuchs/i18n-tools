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
    index.each(*args.map { |arg| arg.dup }) { |occurence| puts occurence.to_s }
  end
end

command :replace do |c|
  c.syntax = 'i18n replace [key] [replacement] --index --verbose'
  c.summary = 'Replace keys passed to I18n.t() by something else'
  c.example 'i18n replace', 'i18n replace foo bar --index'
  c.option '--index', 'Use an index'
  c.option '--verbose', 'Output information about index build'
  c.when_called do |args, options|
    search, replacement = args.shift, args.shift
    raise Commander::Runner::InvalidCommandError.new('Wrong number of arguments') unless search && replacement
    I18n::Keys.verbose = options.verbose
    index = I18n::Keys.index(:index => options.index)
    index.each(search.dup, replacement.dup) do |occurence|
      index.replace(occurence, replacement) if I18n::Commands.replace?(occurence, replacement)
    end
  end
end

module I18n
  module Commands
    class << self
      def replace?(occurence, replacement)
        return true if @all
        answer = I18n::Commands.confirm_replacement(occurence, replacement)[0, 1]
        answer == 'a' ? @all = true : answer == 'y'
      end

      def confirm_replacement(occurence, replacement)
        puts occurence.to_s, occurence.context
        msg = "Replace this occurence of the key \"#{occurence.key}\" with \"#{replacement}\"? [Y]es [N]o [A]ll"
        answer = ask(msg, %w(y yes n no a all)) do |q|
          q.case = :downcase
          q.readline = true
        end
      end
    end
  end
end