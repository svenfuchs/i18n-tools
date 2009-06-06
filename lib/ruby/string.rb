require 'ruby/node'

module Ruby
  class String < Node
    attr_accessor :contents, :literal

    def initialize(contents = [])
      @contents = contents.each { |c| c.parent = self }
      position_from(contents.first, quote_open.length) unless contents.empty?
    end
    
    def children
      contents
    end

    def <<(content)
      @contents << content.tap { |c| c.parent = self } if content.is_a?(Node)
      position_from(contents.first, quote_open.length) unless contents.empty?
      self
    end

    # no idea what this means tbh
    def literal?
      !!@literal
    end

    def value
      map { |content| content.value }.join
    end

    def to_ruby
      quote_open + map { |content| content.to_ruby }.join + quote_close
    end
    
    def method_missing(method, *args, &block)
      @contents.respond_to?(method) ? @contents.send(method, *args, &block) : super
    end

    protected

      def quote_open
        first ? first.quote.tap { |char| char.replace("%#{char}") unless ['"', "'"].include?(char) } : '"'
      rescue
        '"'
      end

      def quote_close
        first ? first.quote : '"'
      rescue
        '"'
      end
  end

  class StringContent < Identifier
    def quote
      line[column - 1]
    end
    
    def value
      token
    end
  end
end