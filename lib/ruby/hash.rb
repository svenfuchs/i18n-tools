require 'ruby/node'

module Ruby
  class Hash < Node
    attr_accessor :assocs, :bare

    def initialize(assocs)
      if assocs
        @assocs = assocs.each { |a| a.parent = self }
        position_from(assocs.first, 2) # TODO check for whitespace
      end
    end
    
    def children
      assocs
    end
    
    def [](key)
      each { |assoc| return assoc.value if assoc.key.value == key }
      nil
    end
    
    def []=(key, value)
      each { |assoc| return assoc.value = value if assoc.key.value == key }
      self << Assoc.new(key, value)
      position_from(assocs.first, 2)
      self[key]
    end
    
    def delete(key)
      delete_if { |assoc| assoc.key.value == key }
    end

    def bare?
      !!@bare
    end
    
    def position
      raise "empty hash ... now what?" if empty?
      @position ||= [first.key.row, first.key.column - 2]
    end
    
    def to_hash
      eval(to_ruby(false)) rescue {}
    end

    def to_ruby(bare = self.bare)
      return nil if bare? && empty?
      ruby = bare ? '' : '{ '
      ruby << map { |assoc| assoc.to_ruby }.join(', ')
      ruby << ' }' unless bare
      ruby
    end
    
    def method_missing(method, *args, &block)
      @assocs.respond_to?(method) ? @assocs.send(method, *args, &block) : super
    end
  end

  class Assoc < Node
    attr_reader :key, :value
    
    def initialize(key, value)
      self.key, self.value = key, value
      position_from(key)
    end
    
    def children
      [key, value]
    end

    def value=(value)
      value = Unsupported.new(value) if value && !value.is_a?(Node)
      @value = value.tap { |v| v.parent = self }
    end

    def key=(key)
      key = Unsupported.new(key) unless key.is_a?(Node)
      @key = key.tap { |k| k.parent = self }
    end
    
    def to_ruby
      "#{key.to_ruby} => #{value.to_ruby}"
    end
  end
end